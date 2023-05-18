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

  /**
   * Create call task for account without call task
   * 
   * @param accountIds : list id of accounts
   */
  public static void createCallTaskForAccounts(Set<Id> accountIds) {
    // Get accounts without call task
    List<Account> accounts = AccountService.getAccountsWithoutCallTask(accountIds);

    if (!accounts.isEmpty()) {
      // Create call task for each account
      AccountService.createCallTask(accounts);
    }
  }

  /**
   * Get accounts without call task
   * 
   * @param accountIds : list id of accounts
   * 
   * @return list of accounts
   */
  public static List<Account> getAccountsWithoutCallTask(Set<Id> accountIds) {
    // List of accounts to create task
    List<Account> accountsWithoutCallTask = new List<Account>();

    List<Account> accounts = [SELECT Id, OwnerId, (SELECT Id FROM Tasks WHERE TaskSubtype = 'Call') FROM Account WHERE Id IN :accountIds];
    for (Account account : accounts) {
      if (account.Tasks.size() == 0) {
        accountsWithoutCallTask.add(new Account(
          Id = account.Id,
          OwnerId = account.OwnerId
        ));
      }
    }

    return accountsWithoutCallTask;
  }

  /**
   * Create call task for a list of accounts
   * 
   * @param accounts : list of accounts
   */
  public static void createCallTask(List<Account> accounts) {
    List<Task> tasksToCreate = new List<Task>();

    for (Account account : accounts) {
      tasksToCreate.add(new Task(
        WhatId = account.Id,
        OwnerId = account.OwnerId,
        Subject = 'Call',
        Status = 'Not Started',
        Priority = 'Normal',
        TaskSubtype = 'Call',
        IsReminderSet = true,
        ReminderDateTime = Date.today().addDays(5)
      ));
    }

    insert tasksToCreate;
  }
}