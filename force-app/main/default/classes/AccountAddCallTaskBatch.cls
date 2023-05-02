/**
 * Batch to add call task for accounts without order
 */
public class AccountAddCallTaskBatch implements Database.Batchable<SObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    // Select all accounts without order
    return Database.getQueryLocator('SELECT Id FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)');
  }
  public void execute(Database.BatchableContext bc, List<Account> records) {
    // Set account ids
    Set<Id> accountIds = (new Map<Id,SObject>(records)).keySet();
    // Call AccountService method
    AccountService.createCallTaskForAccounts(accountIds);
  }
  public void finish(Database.BatchableContext bc) {
  }
}