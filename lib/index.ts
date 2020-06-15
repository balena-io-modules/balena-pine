/*
Copyright 2016-2020 Balena Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

/**
 * @module pine
 */

import * as url from 'url';

import * as errors from 'balena-errors';
import { AnyObject, Params, PinejsClientCore } from 'pinejs-client-core';

interface BackendParams {
	apiUrl: string;
	apiVersion: string;
	apiKey?: string;
	request: {
		// TODO: Should be the type of balena-request
		send: (options: AnyObject) => Promise<{ body: any }>;
	};
	auth: import('balena-auth').default;
}): getPine.BalenaPine {
	const { apiUrl, apiVersion, apiKey, request, auth } = param;
	const apiPrefix = url.resolve(apiUrl, `/${apiVersion}/`);

	/**
	 * @class
	 * @classdesc A PineJS Client subclass to communicate with balena.
	 * @private
	 *
	 * @description
	 * This subclass makes use of the [balena-request](https://github.com/balena-io-modules/balena-request) project.
	 */
	class BalenaPine extends PinejsClientCore<BalenaPine> {

		/**
		 * @summary Perform a network request to balena.
		 * @method
		 * @private
		 *
		 * @param {Object} options - request options
		 * @returns {Promise<*>} response body
		 *
		 * @todo Implement caching support.
		 */
		public async _request(
			options: {
				method: string;
				url: string;
				body?: AnyObject;
			} & AnyObject,
		) {
			const hasKey = await auth.hasKey();
			const authenticated = hasKey || (apiKey != null && apiKey.length > 0);

			options = Object.assign(
				{
					apiKey,
					baseUrl: apiUrl,
					sendToken: authenticated && !options.anonymous,
				},
				options,
			);

			try {
				const { body } = await request.send(options);
				return body;
			} catch (err) {
				if (err.statusCode !== 401) {
					throw err;
				}

				// Always return the API error when the anonymous flag is used.
				if (options.anonymous) {
					throw err;
				}

				// We want to allow unauthenticated users to make requests
				// to public resources, but still reject with a NotLoggedIn
				// error if the response ends up being a 401.
				if (!authenticated) {
					throw new errors.BalenaNotLoggedIn();
				}

				throw err;
			}
		}
	}

	const pineInstance = new BalenaPine({
		apiPrefix,
	});

	return Object.assign(pineInstance, {
		API_URL: apiUrl,
		API_VERSION: apiVersion,
		API_PREFIX: apiPrefix,
	});
}

// tslint:disable-next-line:no-namespace
declare namespace getPine {
	// We have to declare this in a namespace to avoid an error around using private types
	// in declaration files
	export class BalenaPine extends PinejsClientCore<BalenaPine> {
		public _request(
			options: {
				method: string;
				url: string;
				body?: AnyObject;
			} & AnyObject,
		): Promise<any>;
	}
}

export = getPine;
