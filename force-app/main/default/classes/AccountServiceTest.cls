/**
 * Class to test the class AccountService
 * 
 * @author Nicolas Padiou
 */
@isTest
public class AccountServiceTest {
  @isTest static void testDisableAccountsWithoutOrders() {
    // Create test Accounts
    Account account = TestDataFactory.createAccount('TestAccount1');
    account.Active__c = true;
    insert account;

    account = [SELECT Id, Active__c FROM Account WHERE Id = :account.Id];
    System.assertEquals(true, account.Active__c);

    // Create Product
    Product2 product = TestDataFactory.createProduct();

    // Generate Pricebook Id
    Id pricebookId = Test.getStandardPricebookId();
  
    // Create a PricebookEntry
    PricebookEntry standardPrice = TestDataFactory.createPricebookEntry(pricebookId, product, 100);

    Order order1 = TestDataFactory.createOrder(account, pricebookId);
    insert order1;

    Set<Id> accountIds = new Set<Id>();
    accountIds.add(account.Id);

    AccountService.disableAccountsWithoutOrders(accountIds);

    account = [SELECT Id, Active__c FROM Account WHERE Id = :account.Id];
    System.assertEquals(true, account.Active__c);

    delete order1;

    AccountService.disableAccountsWithoutOrders(accountIds);

    account = [SELECT Id, Active__c FROM Account WHERE Id = :account.Id];
    System.assertEquals(false, account.Active__c);
  }
}