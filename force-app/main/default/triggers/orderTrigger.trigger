trigger orderTrigger on Order (after update) {
    try {
        OrderHelper.AfterUpdate(Trigger.New, Trigger.oldMap.values());
    }catch ( Exception e ){
        System.debug('Exception in trigger -- '+e.getMessage());
    }
}