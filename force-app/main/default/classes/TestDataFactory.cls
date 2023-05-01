/**
 * Data Factory used in Unit Test to create Test objects
 * 
 * @author Nicolas Padiou
 */
@IsTest
public class TestDataFactory {
  /**
   * Create a test object Order
   * 
   * @param unitPrice The unit product price in the order
   * @param shipmentCost The shipment cost of the order
   * @param account The account of the order
   * 
   * @return an instance of Order
   */
  public static Order createOrder(Account account, Id pricebookId) {
    Date startDate = System.today().addDays(-1);

    // Create a Contract
    Contract contract = TestDataFactory.insertContract(account, startDate);

    // Create a new order
    Order order = new Order(
      ContractId = contract.Id,
      AccountId = account.Id,
      EffectiveDate = startDate,
	    Status = 'Draft',
      PriceBook2Id = pricebookId
    );
    
    return order;
  }

  /**
   *  Create a test object Order
   * 
   * @param orderId Id of the order
   * @param product A product object
   * @param unitPrice Price of the product
   * @param quantity Quantity of product
   * @param standardPriceId Id of the standard price
   * 
   * @return an instance of OrderItem
   */
  public static OrderItem createOrderItem(Id orderId, Product2 product, Decimal unitPrice, Integer quantity, Id standardPriceId) {
    OrderItem orderItem = new OrderItem(
      OrderId = orderId,
      Quantity = quantity,
      UnitPrice = unitPrice,
      Product2id = product.Id,
      PricebookEntryId = standardPriceId
    );
    return orderItem;
  }

  /**
   * Create a test product
   * 
   * @return an instance of Product
   */
  public static Product2 createProduct() {
    Product2 product = new Product2(
      Name = 'Test Product',
      Description='Test Product',
      productCode = 'ABC',
      isActive = true
    );
    insert product;

    return product;
  }

  /**
   * Create a test account
   * @param name The name of the account
   * 
   * @return an instance of Account
   */
  public static Account createAccount(String name) {
    Account account = new Account(
      Name = name,
      Industry = 'Banking'
    );

    return account;
  }

  /**
   * Insert a test contract
   * 
   * @param account The account attached to the contract
   * @param startDate The start date of the contract
   * 
   * @return an instance of Contract
   */
  public static Contract insertContract(Account account, Date startDate) {
    Contract contract = new Contract(
      AccountId = account.Id,
      Status = 'Draft',
      StartDate = startDate,
      ContractTerm = 10
    );
    insert contract;

    contract.Status = 'Activated';
    update contract;

    return contract;
  }

  /**
   * Create a PricebookEntry test
   * 
   * @param pricebookId The id of the pricebook
   * @param product The product attached to the pricebook entry
   * @param unitPrice The unit price of the pricebook entry
   * 
   * @return an instance of PricebookEntry
   */
  public static PricebookEntry createPricebookEntry(Id pricebookId, Product2 product, Decimal unitPrice){
    PricebookEntry standardPrice = new PricebookEntry(
      Pricebook2Id = pricebookId,
      Product2Id = product.Id,
      UnitPrice = unitPrice,
      IsActive = true,
      UseStandardPrice = false
    );
    insert standardPrice ;

    return standardPrice;
  }

  /**
   * Create a test contract
   * 
   * @param account The account attached to the contract
   * @param startDate The start date of the contract
   * 
   * @return an instance of Contract
   */
  public static Contract createContract(Id accountId) {
    Date startDate = System.today().addDays(-1);
    Contract contract = new Contract(
      AccountId = accountId,
      Status = 'Draft',
      StartDate = startDate,
      ContractTerm = 10
    );
    return contract;
  }

  /**
   * Create a test object Order
   * 
   * @param shipmentCost The shipment cost of the order
   * @param accountId The account Id of the order
   * @param pricebookId The pricebook Id of the order
   * @param contractId The contract Id of the order
   * 
   * @return an instance of Order
   */
  public static Order createOrder(Id accountId, Id pricebookId, Id contractId) {
    Date startDate = System.today().addDays(-1);

    // Create a new order
    Order order = new Order(
      ContractId = contractId,
      AccountId = accountId,
      EffectiveDate = startDate,
	    Status = 'Draft',
      PriceBook2Id = pricebookId
    );
    
    return order;
  }
}