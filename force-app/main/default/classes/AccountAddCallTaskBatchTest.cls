@isTest
public class AccountAddCallTaskBatchTest {
  @TestSetup
  static void setup(){
    List<Account> accounts = new List<Account>();
    accounts.add(TestDataFactory.createAccount('TestAccount1'));
    accounts.add(TestDataFactory.createAccount('TestAccount2'));
    accounts.add(TestDataFactory.createAccount('TestAccount3'));
    insert accounts;
  }
  @isTest static void test() {
    Test.startTest();
    AccountAddCallTaskBatch batch = new AccountAddCallTaskBatch();
    Database.executeBatch(batch);
    Test.stopTest();

    List<Task> tasks = [SELECT Id FROM Task];
    System.assertEquals(3, tasks.size());

    List<Account> accounts = [SELECT Id, OwnerId, (SELECT Id, Subject, OwnerId, Priority, Status  FROM Tasks WHERE TaskSubtype = 'Call') FROM Account];
    for(Account account : accounts) {
      System.assertEquals(1, account.Tasks.size());
      Task task = account.Tasks[0];
      System.assertEquals('Call', task.Subject);
      System.assertEquals(account.OwnerId, task.OwnerId);
      System.assertEquals('Normal', task.Priority);
      System.assertEquals('Not Started', task.Status);
    }
  }
}