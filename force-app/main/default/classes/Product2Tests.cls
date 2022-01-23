@isTest (seeAllData=false)
private class Product2Tests {

    @testSetup
    public static void SetupTestData(){  
        
        CollaborationGroup ChatterGroup = new CollaborationGroup(
            Name = 'TEST'+constants.INVENTORY_ANNOUNCEMENTS,  
            CollaborationType = 'Public',
            CanHaveGuests = false,
            IsArchived = false,
            IsAutoArchiveDisabled = true
        );
        insert ChatterGroup;
        
    }

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    @isTest 
    static void Product2Extension_UnitTest(){
        Test.setCurrentPage(Page.Product2New);
        Product2Extension ext = new Product2Extension(new ApexPages.StandardController(new Product2()));
        Test.startTest();
        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
        
        List<Product2> testPrds = TestDataFactory.ConstructProducts(Constants.DEFAULT_ROWS);
        List<PricebookEntry> testPbes = TestDataFactory.ConstructPricebookEntries(testPrds);
        for(integer i=0;i<testPrds.size();i++){
            ext.productsToInsert[i].productRecord=testPrds[i];
            ext.productsToInsert[i].priceBookEntryRecord=testPbes[i];
        }

        ext.GetFamilyOptions();

        ext.Save();
        Test.stopTest();
        System.assertEquals(Constants.DEFAULT_ROWS, [SELECT count() from Product2]);
        System.assertEquals(Constants.DEFAULT_ROWS, [SELECT count() from PricebookEntry]);
     
        
    }

    @isTest 
    static void Product2Trigger_UnitTest() {
        Product2 testPrd = new Product2(Name='Test Product',Initial_Inventory__c=100,IsActive=true,Family='Entree');
        insert testPrd;
        TestDataFactory.ConstructCollaborationGroup();
        Test.startTest();
        testPrd.Quantity_Ordered__c=90;
        update testPrd;
        Test.stopTest();
       

    }
    
    /*
    @isTest
    static void Product2Extension_UnitTest(){
        PageReference pageRef = Page.Product2New;
        Test.setCurrentPage(pageRef);
        Product2 prod = new Product2(name='Test',isActive=true);        
        ApexPages.StandardController stdcontroller = new 
        ApexPages.StandardController(prod);        
        Product2Extension ext = new Product2Extension(stdcontroller);        
        System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
        
        ext.addRows();
        System.assertEquals(Constants.DEFAULT_ROWS * 2, 
        ext.productsToInsert.size());
        
        for (Integer i = 0; i < 5; i++) {
            Product2Extension.ProductWrapper wrapper = ext.productsToInsert[i];
            
            Product2 testProd = new Product2();
            testProd.Name = 'Test Product ' + i;
            testProd.IsActive = true;
            testProd.Initial_Inventory__c = 20;
            testProd.Family = Constants.PRODUCT_FAMILY[0].getValue();
            wrapper.productRecord = testProd;
            
            PricebookEntry testPBEntry = new PricebookEntry();
            testPBEntry.IsActive = true;
            testPBEntry.UnitPrice = 10;
            wrapper.pricebookEntryRecord = testPBEntry;
        }
        
        Test.startTest();
        ext.save();
        Test.stopTest();
        
        ext.GetFamilyOptions();
        ext.GetInventory();
        List<Product2> createdProducts = [
            SELECT
                Id
            FROM
                Product2
        ];
        System.assertEquals(5, createdProducts.size());
    }
    
    @isTest
    static void Product2Trigger_UnitTest(){
        TestDataFactory.InsertTestData(5); 
        test.startTest();
        
        Order rec = [SELECT id, Status FROM Order LIMIT 1];
        Product2 prod = [SELECT Family,Id,Name,Quantity_Ordered__c,Quantity_Remaining__c FROM Product2 WHERE Name LIKE 'Test Product%' LIMIT 1];
   
        rec.status = constants.ACTIVATED_ORDER_STATUS;      
        Update rec;
        Product2 updatedprod = [SELECT Family,Id,Name,Quantity_Ordered__c,Quantity_Remaining__c FROM Product2 limit 1];
        
        TestDataFactory.VerifyQuantityOrdered(prod,updatedprod,constants.DEFAULT_ROWS);
        Test.stopTest();
    }
    */
}