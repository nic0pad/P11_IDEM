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

    Set<Id> orderIds = new Set<Id>();
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

  @isTest static void testCanSaved() {
    // Create test Accounts
    Account account1 = TestDataFactory.createAccount('TestAccount1');
    insert account1;

    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
  
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

    Set<Id> orderIds = new Set<Id>();
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
}