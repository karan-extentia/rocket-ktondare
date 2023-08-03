public with sharing class Rocket_GlobalUtil {

    @AuraEnabled(cacheable=true)
    public static Id resolveCommunityIdToWebstoreId(String communityId) {
        WebStoreNetwork network = Rocket_CommunityFactory.getWebStoreNetworkForCommunity(communityId);
        return network.WebStoreId;
    }

    @AuraEnabled(cacheable=true)
    public static void setCommunityIdInCache(String communityId) {
        Cache.Session.put('local.NavMenuPartition.navcommunityId', communityId);
    }

    public static String getCommunityIdFromCache() {
        String communityId = '';
        if (Cache.Session.contains('local.NavMenuPartition.navcommunityId')) {
            communityId = (String)Cache.Session.get('local.NavMenuPartition.navcommunityId');
        }
        return communityId;
    }
}