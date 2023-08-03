public without sharing abstract class Rocket_AccountFactory {
    public static String getAccountIdByUserId(String userId) {
        String accountId;
        try {
            accountId = [
                SELECT AccountId
                FROM
                User
                WHERE ID=:userId
                LIMIT 1
            ].AccountId;
        }catch(Exception e){
            Rocket_Event_Logger.error(e,'Error getting AccountId from User');
        }

        return accountId != null ? accountId : '000000000000000';
    }

    public static String getAccountId(String accountNumber){
        Account accountResult;
        try{
            accountResult = [
                SELECT Id
                FROM Account
                WHERE Account_Identification_Number__c=:accountNumber
                LIMIT 1
            ];
        }catch(Exception e){
            Rocket_Event_Logger.error(e,'Error getting AccountId from Account Number');
        }

        return accountResult != null ? accountResult.Id : null;
    }

    public static ID insertContactPointAddress(ContactPointAddress con){
        try{
            if(Schema.sObjectType.ContactPointAddress.isCreateable()){
                insert con;
            }
        }catch(Exception e){
            Rocket_Event_Logger.error(e,'There was an error getting the contact point address.');
        }

        return con.id;
    }

    public static ID insertContactPointPhone(ContactPointPhone conPhone){
        try{
            if(Schema.sObjectType.ContactPointPhone.isCreateable()){
                insert conPhone;
            }
        }catch(Exception e){
            Rocket_Event_Logger.error(e, 'Error generating the Contact Point which caused an Exception');
        }

        return conPhone.id;
    }

    /**
     * @description An inner class that stores address details.
     */
    public class AddressData {
        @AuraEnabled public String street { get; set; }
        @AuraEnabled public String city { get; set; }
        @AuraEnabled public String state { get; set; }
        @AuraEnabled public String postalCode { get; set; }
        @AuraEnabled public String country { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String companyName { get; set; }
        @AuraEnabled public String parentId { get; set; }
        @AuraEnabled public String phoneNumber {get;set;}
        @AuraEnabled public String addToBook {get;set;}
    }

    // public static UserDetail getUserDetail(String userId) {
    //     UserDetail userDetail = new UserDetail();

    //     try {
    //         User user = [
    //             SELECT Id,
    //                 username,
    //                 email,
    //                 userroleid,
    //                 contactid
    //                 FROM User
    //                 WHERE id = :userId
    //                 LIMIT 1
    //         ];

    //         Contact contact = [
    //                 SELECT Id,
    //                 mailingaddress,
    //                 phone,
    //                 accountid
    //                 FROM Contact
    //                 WHERE id = :user.ContactId
    //                 LIMIT 1
    //             ];

    //         Account account = [
    //                 SELECT Id,
    //                 name,
    //                 accountnumber
    //                 FROM Account
    //                 WHERE id = :contact.accountId
    //                 LIMIT 1
    //             ];

    //         userDetail.accountId = account.id;
    //         userDetail.accountName = account.Name;
    //         userDetail.accountNumber = account.AccountNumber;
    //         userDetail.contactId = contact.id;
    //         userDetail.contactPhone = contact.phone;
    //         userDetail.contactAddress = contact.MailingAddress;
    //         userDetail.userid = user.id;
    //         userDetail.username = user.username;
    //         userDetail.email = user.Email;
    //         // userDetail.roleId = role.id;
    //         // userDetail.roleName = role.name;
    //         System.debug('-------------');
    //         System.debug(userDetail);
    //     } catch(e) {

    //     }


    //     return userDetail;
    // }

        /**
     * @description Get user details including contact and account if avaialble
     * @param userId user record ID
     * @return UserDetail
     */
    public static UserDetail getUserDetail(String userId){
        UserDetail userDetail = new UserDetail();
        try{
            // Get User data and adjacent object data
            User user = [
                SELECT id,
                username,
                email,
                userroleid,
                userrole.name,
                contactid,
                contact.phone,
                contact.mailingaddress,
                contact.accountid,
                contact.account.name,
                contact.account.accountnumber
                FROM User
                WHERE id = :userid AND Profile.Name = :'Custom Customer Community Plus User'
                LIMIT 1
            ];

            //Set the attributes of our wrapper class
            userDetail.accountId = user.contact.accountid;
            userDetail.accountName = user.contact.account.Name;
            userDetail.accountNumber = user.contact.account.AccountNumber;
            userDetail.contactId = user.contactid;
            userDetail.contactPhone = user.contact.phone;
            userDetail.contactAddress = user.contact.MailingAddress;
            userDetail.userid = user.id;
            userDetail.username = user.username;
            userDetail.email = user.Email;
            userDetail.roleId = user.userroleid;
            userDetail.roleName = user.userrole.name;

        }catch(Exception e){
            Rocket_Event_Logger.error(e, 'Error on getting user details');
        }

        return userDetail;
    }

    /**
     * @description Customer User Details
     */
    public class UserDetail {
        //id, username, and email from User object
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String username { get; set; }
        @AuraEnabled public String email { get; set; }

        //UserRole on the user object
        @AuraEnabled public String roleId { get; set; }
        @AuraEnabled public String roleName { get; set; }
        @AuraEnabled public String contactId { get; set; }

        //Mailing address from Contact on user
        @AuraEnabled public Address contactAddress { get; set; }

        //Phone attribute from Contact on user
        @AuraEnabled public String contactPhone { get; set; }

        //Contains the account attributes from the contact on account
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public String accountNumber { get; set; }
    }
}