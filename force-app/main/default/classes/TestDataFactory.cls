/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup grp = new CollaborationGroup();
        
        grp.Name='TEST'+Constants.INVENTORY_ANNOUNCEMENTS;
        grp.CollaborationType='Public';
        grp.IsAutoArchiveDisabled = true;
        return grp;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Schema.PicklistEntry> familyLst = Constants.PRODUCT_FAMILY;
        List<Product2> testPrdts = new List<Product2>();
        for(Integer i=0;i<cnt;i++){
            Integer index = Math.mod(i, familyLst.size());
            testPrdts.add(new Product2(Name='TEST_PRODUCT_'+i,isActive=TRUE,Initial_Inventory__c=10,Family=familyLst[index].getValue()));
        }
       return testPrdts;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
      List<PricebookEntry> testPricebookEntries = new List<PricebookEntry>();
        for(Product2 prod:prods){
            testPricebookEntries.add(new PricebookEntry(Product2Id=prod.Id,PriceBook2Id=Constants.STANDARD_PRICEBOOK_ID,IsActive=TRUE,UnitPrice=5));
        }
        return testPricebookEntries;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> testAcc = new List<Account>();
        for(Integer i=1;i<=cnt;i++){
            testAcc.add(new Account(Name='TEST_ACCOUNT_'+i));
        }
        return testAcc;
    }
    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> testCnts = new List<Contact>();
        for(Integer i=0;i<cnt;i++){
            Integer index = Math.mod(i, accts.size());
            testCnts.add(new Contact(LastName='TEST_CONTACT_'+i,AccountId=accts[index].Id));
        }
        return testCnts;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> testOrds = new List<Order>();
        for(Integer i=0;i<cnt;i++){
            Integer index = Math.mod(i, accts.size());
            testOrds.add(new Order(PriceBook2Id=Constants.STANDARD_PRICEBOOK_ID,Name='TEST_ORDER'+i,AccountId=accts[index].Id,EffectiveDate=System.today()-10,Status='Draft'));
        }
        return testOrds;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> testOrdItms = new List<OrderItem>();
        for(Integer i=0;i<cnt;i++){
            Integer indexP = Math.mod(i, pbes.size());
            Integer indexO = Math.mod(i, ords.size());
            testOrdItms.add(new OrderItem(PricebookEntryId=pbes[indexP].Id,OrderId=ords[indexO].Id,Quantity=Constants.DEFAULT_ROWS,UnitPrice=10));
        }        
        return testOrdItms;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        List<Account> acts = ConstructAccounts(cnt);
        insert acts;
        List<Contact> cnts = ConstructContacts(cnt, acts);
        insert cnts;
        List<Product2> prds = ConstructProducts(cnt);
        insert prds;
        List<PricebookEntry> prcbookEntries = ConstructPricebookEntries(prds);
        insert prcbookEntries;
        List<Order> ords = ConstructOrders(cnt,acts);
        insert ords;
        List<OrderItem> ordItems = ConstructOrderItems(cnt,prcbookEntries,ords);
        insert ordItems;
    }
    
    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered){        
        System.assertEquals(originalProduct.Quantity_Ordered__c+qtyOrdered,updatedProduct.Quantity_Ordered__c);
    }

}