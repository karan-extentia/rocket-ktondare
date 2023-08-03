public without sharing class Rocket_CommunityFactory {
    public static Network getNetworkForCommunity(String communityId){
        try{
            Network network = [
                SELECT Name,
                    UrlPathPrefix
                FROM Network
                WHERE Id = :communityId
            ];

            return network;
        } catch (Exception e){
            Rocket_Event_Logger.error(e,'Error getting network with community Id: ' + communityId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static WebStoreNetwork getWebStoreNetworkForCommunity(String communityId){
        try{
            WebStoreNetwork network = [
                SELECT WebStoreId
                FROM WebStoreNetwork
                WHERE NetworkId = :communityId
                LIMIT 1
            ];

            return network;
        } catch (Exception e){
            Rocket_Event_Logger.error(e,'Error getting webstore network with community Id:' + communityId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static WebStore getWebStore(String webStoreId){
        try{
            WebStore webStore = [
                SELECT Id, Price_Integration__c
                FROM WebStore
                WHERE Id = :webStoreId
                LIMIT 1
            ];

            return webStore;
        } catch (Exception e){
            Rocket_Event_Logger.error(e,'Error getting webstore :' + webStoreId);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Id getCurrentNetworkId(){
        return Network.getNetworkId();
    }
}