trigger product2Trigger on Product2 (after update) {
    try {
        Product2Helper.AfterUpdate((List<Product2>)trigger.new,(List<Product2>)trigger.old);
    } catch ( Exception e ){
        //A good developer would do something with this Exception!
        System.debug('Exception in trigger -- '+e.getMessage());
    }
}