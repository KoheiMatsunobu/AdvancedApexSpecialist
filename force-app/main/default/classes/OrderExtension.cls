/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}
    
    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;
    
    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        loadInitialOrderItemData();
        loadPriceBookentry();
    }
    
    public void loadPriceBookentry() {
        //価格票エントリ SOQLクエリ作成
        String query = '';
        query += 'SELECT';
        query += '        Id';
        query += '       ,Name';
        query += '       ,Pricebook2Id';
        query += '       ,Product2Id';
        query += '       ,UnitPrice';
        query += '       ,Product2.Name';
        query += '       ,Product2.Quantity_Remaining__c';
        query += '       ,Product2.Family';
        query += ' FROM  PricebookEntry';
        query += ' WHERE isActive= true';

        if (String.isNotBlank(selectedFamily) && selectedFamily != Constants.SELECT_ONE ) {
            query += ' AND Product2.Family = \''+ selectedFamily + '\'';
        }
       
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
        
        loadOrderItem();
    }
    
    public void loadOrderItem() {
        orderItemList = new List<OrderItem>();
        if(standardSetController.getRecords()!=null && standardSetController.getRecords().size() > 0) {
            for (SObject  obj : standardSetController.getRecords()) {
                PricebookEntry entry = (PricebookEntry)obj;
                
                if(orderItemMap.containsKey(entry.product2Id)) {
                    orderItemList.add(orderItemMap.get(entry.product2Id));
                } else{
                    OrderItem item = new OrderItem(
                        Quantity = 0,
                        PricebookEntryId = entry.Id,
                        Product2Id = entry.Product2Id,
                        UnitPrice = entry.UnitPrice,
                        Product2 = entry.Product2
                    );
                    orderItemList.add(item);
                    orderItemMap.put(entry.Product2Id, item);
                }
            }
        }
        
    }
    
    public void loadInitialOrderItemData() {
        for(OrderItem item : orderRecord.OrderItems) {
            orderItemMap.put(item.Product2Id, item);
        }
        loadChartData();
    }
    
    public void loadChartData() {
        this.total = 0;
        pieData = new List<ChartHelper.ChartData>();
        for(OrderItem item : orderItemMap.values()) {
            pieData.add(new ChartHelper.ChartData(item.Product2.Name, (item.UnitPrice * item.Quantity)));
            total = total + (item.UnitPrice*item.Quantity);
        }
    }
    
    public void OnFieldChange(){
        for(OrderItem item : orderItemList){
            orderItemMap.put(item.Product2Id, item);
        }
        
        loadChartData();
    }
    
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        loadPriceBookentry();
    }
    
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems       
        System.Savepoint sp = Database.setSavepoint();

        try {
            if(orderRecord.Pricebook2Id == null) {
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord;

            List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
            List<OrderItem> orderItemsToDelete = new List<OrderItem>();

            for (OrderItem oi : orderItemMap.values()) {
                if(oi.Quantity > 0) {
                    if(oi.OrderId == null) {
                        oi.OrderId = orderRecord.Id;
                    }
                    orderItemsToUpsert.add(oi);
                } else if(oi.Id != null) {
                    orderItemsToDelete.add(new OrderItem(id=oi.Id));
                    oi.Id = null;
                }
            }

            upsert orderItemsToUpsert;
            delete orderItemsToDelete;

        } catch (Exception e){
            Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,Constants.ERROR_MESSAGE));
        }
    }
    
    public void First(){
        standardSetController.first();
        loadOrderItem();
    }
    
    public void Next(){
        standardSetController.next();
        loadOrderItem();
    }
    
    public void Previous(){
        standardSetController.previous();
        loadOrderItem();
    }
    
    public void Last(){
        standardSetController.last();
        loadOrderItem();
    }
    
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
    }
    
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
    }
    
    public Integer GetTotalPages(){
        return (Integer)math.ceil(standardSetController.getResultSize()/(Decimal)Constants.DEFAULT_ROWS);
    }
    
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
    }
    
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE,Constants.SELECT_ONE));
        for(Schema.PicklistEntry entry : Constants.PRODUCT_FAMILY){
            options.add(new SelectOption(entry.getLabel(),entry.getValue()));
        }
        return options;
    }
    
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
            (
                SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                FROM OrderItems
            )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}