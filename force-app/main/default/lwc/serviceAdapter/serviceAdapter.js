import {getSessionContext} from 'commerce/contextApi';
import {getAppContext} from 'commerce/contextApi';
import basePath from '@salesforce/community/basePath';
import LOCALE from '@salesforce/i18n/locale';
import apiVersion from "@salesforce/label/c.Rocket_ApiVersion_Label";

const isPreview = async () => {
    let session = await getSessionContext();
    return session.isPreview;
}

const getWebstoreId = async () => {
    let context = await getAppContext();
    return context.webstoreId;
}

const getCommunityId = async () => {
    let context = await getAppContext();
    return context.communityId;
}

const getLanguage = async () => {
    return LOCALE.replace('_', '-');
}

const getEffectiveAccountId = async () => {
    let session = await getSessionContext();
    return session.effectiveAccountId;
}

const getEndpointData = async (endpoint) => {
    let jsonData = {};
    let context = await getAppContext();
    let endpointPath = `..${basePath}/webruntime/api/services/data/${apiVersion}/commerce/webstores/${context.webstoreId}/${endpoint}`;

    try {
        const response = await fetch(endpointPath, {
            method: "GET"
        });
        if (response.ok) {
            jsonData = await response.json();
        }
    } catch (error) {
        console.error(error);
    }

    return jsonData;
}

const getEndpointDataWithNoBasePath = async (endpoint) => {
    let jsonData = {};
    let context = await getAppContext();
    let endpointPath = `../../webruntime/api/services/data/${apiVersion}/commerce/webstores/${context.webstoreId}/${endpoint}`;

    try {
        const response = await fetch(endpointPath, {
            method: "GET"
        });
        if (response.ok) {
            jsonData = await response.json();
        }
    } catch (error) {
        console.error(error);
    }

    return jsonData;
}

const deleteEndpointData = async (endpoint) => {
    let context = await getAppContext();
    let endpointPath = `..${basePath}/webruntime/api/services/data/${apiVersion}/commerce/webstores/${context.webstoreId}/${endpoint}`;

    try {
        const response = await fetch(endpointPath, {
            method: "DELETE"
        });

        return response;

    } catch (error) {
        console.error(error);
    }

}

const patchEndpointData = async (endpoint, payload) => {
    let context = await getAppContext();

    let endpointPath = `../${basePath}/webruntime/api/services/data/${apiVersion}/commerce/webstores/${context.webstoreId}/${endpoint}`;

    try {
        const response = await fetch(endpointPath, {
            method: "PATCH",
            body: payload
        });
        if (response.ok) {
            jsonData = await response.json();
        }
        return jsonData;

    } catch (error) {
        console.error(error);
    }

}

const postEndpointData = async (endpoint, payload) => {
    let context = await getAppContext();
    let endpointPath = `../${basePath}/webruntime/api/services/data/${apiVersion}/commerce/webstores/${context.webstoreId}/${endpoint}`;

    try {
        const response = await fetch(endpointPath, {
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            method: "POST",
            credentials: "include",
            body: JSON.stringify(payload)
        });
        if (response.ok) {
            jsonData = await response.json();
        } else {
            console.log(response);
        }

        return response;

    } catch (error) {
        console.error(error);
    }

}

export {
    isPreview,
    getLanguage,
    getWebstoreId,
    getEffectiveAccountId,
    getEndpointData,
    deleteEndpointData,
    patchEndpointData,
    postEndpointData,
    getCommunityId,
    getEndpointDataWithNoBasePath
};