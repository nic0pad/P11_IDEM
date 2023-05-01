/**
 * Class with methods related to Account object
 * 
 * @author Nicolas Padiou
 */
public with sharing class AccountService {
  /**
   * Disable accounts without orders
   * 
   * @param accountIds : list id of accounts to disabled if has no orders
   */
  public static void disableAccountsWithoutOrders(Set<Id> accountIds) {
    // List of accounts to update
    List<Account> accountsToUpdate = new List<Account>();

    // For each account, check if account has order
    List<Account> accounts = [SELECT Id, (Select id, name from Orders) FROM Account WHERE Id IN :accountIds];
    for (Account account : accounts) {
      if (account.Orders.size() == 0) {
        accountsToUpdate.add(new Account(
          Id = account.Id,
          Active__c = false
        ));
      }
    }

    // Update accounts
    update accountsToUpdate;
  }
}