/**
 * Class to test the class OrderService and the trigger OrderTrigger
 * 
 * @author Nicolas Padiou
 */
@isTest
public class OrderServiceTest {
  @isTest static void testGetNumberOfProducts() {
    // Create test Accounts
    Account account1 = TestDataFactory.createAccount('TestAccount1');
    insert account1;

    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
  
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

    Order order1 = TestDataFactory.createOrder(account1, pricebookId);
    insert order1;

    Decimal numberOfOrderItems = OrderService.getNumberOfOrderItems(order1.Id);
    System.assertEquals(0, numberOfOrderItems);

    // Add products to order
    List<OrderItem> orderItems = new List<OrderItem>();
    orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 1000, 1, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(order1.Id, product, 2000, 2, standardPrice.Id));
    insert orderItems;

    numberOfOrderItems = OrderService.getNumberOfOrderItems(order1.Id);
    System.assertEquals(2, numberOfOrderItems);
  }

  @isTest static void testHasActivated() {
    Boolean activated = OrderService.hasActivated('Draft', 'Draft');
    System.assertEquals(false, activated);

    activated = OrderService.hasActivated('Activated', 'Draft');
    System.assertEquals(true, activated);
  }

  @isTest static void testCanSavedTrue() {
    // Create test Accounts
    Account account1 = TestDataFactory.createAccount('TestAccount1');
    insert account1;

    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
  
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

    Order oldOrder = TestDataFactory.createOrder(account1, pricebookId);
    insert oldOrder;

    // Add products to order
    List<OrderItem> orderItems = new List<OrderItem>();
    orderItems.add(TestDataFactory.createOrderItem(oldOrder.Id, product, 1000, 1, standardPrice.Id));
    orderItems.add(TestDataFactory.createOrderItem(oldOrder.Id, product, 2000, 2, standardPrice.Id));
    insert orderItems;

    Order newOrder = [SELECT Id, Status FROM Order WHERE Id = :oldOrder.Id];
    newOrder.Status = 'Activated';
    update newOrder;

    Boolean canSaved = OrderService.canSaved(newOrder, oldOrder);
    System.assertEquals(true, canSaved);
  }

  @isTest static void testCanSavedFalse() {
    // Create test Account
    Account account = TestDataFactory.createAccount('TestAccount1');
    insert account;

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();

    // Create draft Order
    Order order = TestDataFactory.createOrder(account, pricebookId);
    insert order;

    // Activate order
    order.Status = 'Activated';
    Test.startTest();
    Database.UpsertResult result = Database.upsert(order, false);
    Test.stopTest();

    // Verify
    System.assert(!result.isSuccess());
    System.assert(result.getErrors().size() > 0);
    System.assertEquals('Add products to activate order !', result.getErrors()[0].getMessage());
  }

  @isTest static void testDisableAccountsWithoutOrders() {
    // Create test Accounts
    Account account = TestDataFactory.createAccount('TestAccount1');
    account.Active__c = true;
    insert account;

    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
  
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

    Order order1 = TestDataFactory.createOrder(account, pricebookId);
    insert order1;

    account = [SELECT Id, Active__c FROM Account WHERE Id = :account.Id];
    System.assertEquals(true, account.Active__c);

    delete order1;

    account = [SELECT Id, Active__c FROM Account WHERE Id = :account.Id];
    System.assertEquals(false, account.Active__c);
  }
}