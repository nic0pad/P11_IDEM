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

  @isTest static void testGetAccountsWithoutCallTask() {
    List<Account> accounts = new List<Account>();
    accounts.add(TestDataFactory.createAccount('TestAccount1'));
    accounts.add(TestDataFactory.createAccount('TestAccount2'));
    accounts.add(TestDataFactory.createAccount('TestAccount3'));
    insert accounts;

    Set<Id> accountIds = new Map<Id, SObject>([SELECT Id FROM Account]).keySet();

    List<Account> accountsWithoutCallTask = AccountService.getAccountsWithoutCallTask(accountIds);

    System.assertEquals(3, accountsWithoutCallTask.size());

    Task task = new Task(
      WhatId = new List<Id> (accountIds)[0],
      Subject = 'Call',
      Status = 'Not Started',
      Priority = 'Normal',
      TaskSubtype = 'Call',
      ActivityDate = Date.today().addDays(5)
    );
    insert task;

    accountsWithoutCallTask = AccountService.getAccountsWithoutCallTask(accountIds);

    System.assertEquals(2, accountsWithoutCallTask.size());
  }

  @isTest static void testCreateCallTask() {
    // Setup test data
    // Create a unique UserName
    String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
    // This code runs as the system user
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' or Name = 'Utilisateur standard'];
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    LocaleSidKey='en_US', ProfileId = p.Id,
    TimeZoneSidKey='America/Los_Angeles',
      UserName=uniqueUserName);

    System.runAs(u) {
        // The following code runs as user 'u'
        System.debug('Current User: ' + UserInfo.getUserName());
        System.debug('Current Profile: ' + UserInfo.getProfileId());
    }
    
    List<Account> accounts = new List<Account>();
    accounts.add(TestDataFactory.createAccount('TestAccount1'));
    accounts.add(TestDataFactory.createAccount('TestAccount2'));
    accounts.add(TestDataFactory.createAccount('TestAccount3'));
    insert accounts;

    AccountService.createCallTask([SELECT Id, OwnerId FROM Account]);

    List<Task> tasks = [SELECT Id FROM Task];
    System.assertEquals(3, tasks.size());

    accounts = [SELECT Id, OwnerId, (SELECT Id, Subject, OwnerId, Priority, Status, IsReminderSet, ReminderDateTime  FROM Tasks WHERE TaskSubtype = 'Call') FROM Account];
    for(Account account : accounts) {
      System.assertEquals(1, account.Tasks.size());
      Task task = account.Tasks[0];
      System.assertEquals('Call', task.Subject);
      System.assertEquals(account.OwnerId, task.OwnerId);
      System.assertEquals('Normal', task.Priority);
      System.assertEquals('Not Started', task.Status);
      System.assertEquals(true, task.IsReminderSet);
      System.assertEquals(Date.today().addDays(5), task.ReminderDateTime);
    }
  }
}