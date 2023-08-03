@isTest
private class Rocket_WSF_Inventory_Test {
    @isTest
    static void testGetInventory() {
        // Create test data
        List<String> products = new List<String>{'SKU1', 'SKU2', 'SKU3'};

        // Mock the external callout response
        Test.setMock(HttpCalloutMock.class, new Rocket_WSF_HttpMock());

        // Call the method to test
        Test.startTest();
        String result = Rocket_WSF_Inventory.getInventory(products);
        Test.stopTest();

        // Perform assertions
        System.assertEquals('{"example":"test"}', result, 'The inventory response does not match the expected result');
    }
}