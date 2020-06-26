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
}

/**
 * @class
 * @classdesc A PineJS Client subclass to communicate with balena.
 *
 * @description
 * This subclass makes use of the [balena-request](https://github.com/balena-io-modules/balena-request) project.
 */
export class BalenaPine extends PinejsClientCore<BalenaPine> {
	public API_URL: string;
	public API_VERSION: string;

	constructor(params: Params, public backendParams: BackendParams) {
		super({
			...params,
			apiPrefix: url.resolve(
				backendParams.apiUrl,
				`/${backendParams.apiVersion}/`,
			),
		});

		this.backendParams = backendParams;
		this.API_URL = backendParams.apiUrl;
		this.API_VERSION = backendParams.apiVersion;
	}

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
		const { apiKey, apiUrl, auth, request } = this.backendParams;

		const hasKey = await auth.hasKey();
		const authenticated = hasKey || (apiKey != null && apiKey.length > 0);

		options = {
			apiKey,
			baseUrl: apiUrl,
			sendToken: authenticated && !options.anonymous,
			...options,
		};

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
