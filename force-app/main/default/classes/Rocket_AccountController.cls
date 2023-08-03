public with sharing class Rocket_AccountController extends Rocket_AccountFactory {
    @AuraEnabled
    public static string createContactAddress(AddressData addressInfo){
        try{
            ContactPointAddress con = new ContactPointAddress();
            con.Name = addressInfo.name;
            con.Street = addressInfo.street;
            con.City = addressInfo.city;
            con.State = addressInfo.state;
            con.PostalCode = addressInfo.postalCode;
            Id conPhoneId = createContactPointPhone(addressInfo.phoneNumber, addressInfo.parentId);
            con.ContactPointPhoneId = conPhoneId;
            con.ParentId = addressInfo.parentId;
            con.AddressType = 'Shipping';
            con.IsDefault = true;
            con.Country = addressInfo.country;
            con.UsageType =  addressInfo.addToBook == 'true' ? 'DropShip' : '';

            Id contactPointId = insertContactPointAddress(con);

            return contactPointId;
        }

        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static ID createContactPointPhone(String teleNum, string accId){
        try{
            ContactPointPhone conPhone = new ContactPointPhone();
            conPhone.telephoneNumber = teleNum;
            conPhone.ParentId = accId;

            Id conPhoneId = insertContactPointPhone(conPhone);

            return conPhoneId;
        }

        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String getUserAccountID() {
        String userId = UserInfo.getUserId();
        String contactId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
        return [SELECT AccountId FROM Contact WHERE Id = :contactId].AccountId;
    }

    @AuraEnabled(cacheable=true)
    public static string getAccountByUserId(String userId) {
        try {
            return getAccountIdByUserId(userId);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean accountNumberValid(String accountNumber) {
        try {
            return getAccountId(accountNumber) != null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string registerUser(String accountNumber, String firstName, String lastName, String username, String email, String password,
                                      String street, String city, String state, String zip, String profileName, String permissionSets){
        try{

            String accountId = '';

            if(accountNumber == '' || accountNumber == null) {
                Account account = new Account();
                account.Name = firstName + ' ' + lastName;

                insert account;

                accountId = account.Id;

                AddressData addressData = new AddressData();
                addressData.name = firstName + ' ' + lastName;
                addressData.street = street;
                addressData.city = city;
                addressData.state = state;
                addressData.postalCode = zip;
                addressData.parentId = account.Id;
                addressData.country = 'US';

                String contactPointId = createContactAddress(addressData);
            } else {
                accountID = getAccountId(accountNumber);
            }

            Id profileId = [SELECT Id FROM Profile WHERE Name =:profileName LIMIT 1].Id;

            Contact contact = new Contact();
            contact.FirstName = firstName;
            contact.LastName = lastName;
            contact.Email = email;
            contact.AccountId = accountId;

            insert contact;

            String uniqueName = createUniqueCommunityNickName(firstName);

            User user = new User();
            user.firstName = firstName;
            user.lastName = lastName;
            user.Username = username;
            user.Email = email;
            user.CommunityNickname = uniqueName;
            user.ProfileId = profileId;
            user.ContactId = contact.Id;
            user.Alias = uniqueName;
            user.EmailEncodingKey = 'UTF-8';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.LanguageLocaleKey = 'en_US';

            insert user;

            String userId = user.Id;
            System.setPassword(userId, password);

            createPermissionsSets(userId, permissionSets);

            if (userId != null) {
                if (password != null && password.length() > 1) {
                    ApexPages.PageReference pageRef = Site.login(username, password, null);
                    if(pageRef != null) return pageRef.getUrl();
                }
                else {
                    ApexPages.PageReference page = System.Page.SiteRegisterConfirm;
                    page.setRedirect(true);
                    return page.getUrl();
                }
            }

            return '';
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @future
    private static void createPermissionsSets(String userId, String permissionSets)
    {
        List<PermissionSetAssignment> pSetAssignments = new List<PermissionSetAssignment>();

        List<String> ps = permissionSets.split(',');
        List<String> pst = new List<String>();
        for(String s : ps) { pst.add(s.trim());}

        for(PermissionSet pSet : [SELECT Id FROM PermissionSet WHERE Label IN :pst]) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userId;
            psa.PermissionSetId = pSet.Id;
            pSetAssignments.add(psa);
        }
        insert pSetAssignments;
    }

    @AuraEnabled
    public static boolean isEmailExist(String username){
        try {
            List<User> userList = new List<User>();
            userList = [Select Id, Name From User Where Username = :username];
            return !userList.isEmpty();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createUniqueCommunityNickName(String communityNickname) {
        Set<String> communityNicknameSet = new Set<String>();

        for(User usr : [Select Id, CommunityNickname From User Where CommunityNickname != null]){
            communityNicknameSet.add(usr.CommunityNickname);
        }

        String uniqueCommunityNickName;
        if(communityNicknameSet.isEmpty()){
            if(communityNickname.length() > 4){
                uniqueCommunityNickName = communityNickname.substring(0, 4) + String.valueOf( Integer.valueOf(Math.random() * 10000) );
            } else {
                uniqueCommunityNickName = communityNickname + String.valueOf( Integer.valueOf(Math.random() * 10000) );
            }
        } else {
            for(Integer i=1; i <= 9999 ; i++){
                if(communityNickname.length() > 4){
                    uniqueCommunityNickName = communityNickname.substring(0, 4) + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                } else {
                    uniqueCommunityNickName = communityNickname + String.valueOf( Integer.valueOf(Math.random() * 10000) );
                }

                if(!communityNicknameSet.contains(uniqueCommunityNickName)){
                    break;
                }
            }
        }

        return uniqueCommunityNickName;
    }

    /**
    * @description Get details about a commerce user.
    * @author bzhang@shift7digital.com | 07-13-2023
    * @param username
    * @return CustomerUserDetail or null
    **/
    @AuraEnabled(cacheable=true)
    public static UserDetail getUserDetailByUserId(String userId) {
        try {
            UserDetail userDetails = getUserDetail(userId);
            System.debug(JSON.serialize(userDetails));
            return userDetails;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}