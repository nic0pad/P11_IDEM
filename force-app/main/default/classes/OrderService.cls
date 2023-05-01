/**
 * Class with methods related to Order object
 * 
 * @author Nicolas Padiou
 */
public with sharing class OrderService {
  /**
   * Return number of OrderItems for an order
   * 
   * @param orderId : the Id of the order
   * 
   * @return Decimal numberOfOrderItems
   */
  public static Decimal getNumberOfOrderItems(Id orderId) {
    AggregateResult[] result = [SELECT COUNT(Id) numberOfProducts FROM OrderItem WHERE OrderId = :orderId];
    Decimal numberOfOrderItems = 0;
    if (!result.isEmpty()) numberOfOrderItems = (Decimal)result[0].get('numberOfProducts');
    return numberOfOrderItems;
  }

  /**
   * Check if the order can be saved
   * 
   * @param newOrder : the order updated
   * @param oldOrder : the order before update
   * 
   * @return Boolean
   */
  public static Boolean canSaved(Order newOrder, Order oldOrder) {
    if (newOrder.Status != 'Activated') {
      return true;
    }
    if(OrderService.hasActivated(newOrder.Status, oldOrder.Status) == true && OrderService.getNumberOfOrderItems(newOrder.Id) > 0) {
      return true;
    }
    return false;
  }

  /**
   * Check if the status changed to Activated
   * 
   * @param newStatus : the new Status
   * @param oldStatus : the old Status
   * 
   * @return Boolean
   */
  public static Boolean hasActivated(String newStatus, String oldStatus) {
    if(newStatus == 'Activated' && newStatus != oldStatus) {
      return true;
    }
    return false;
  }

  /**
   * Disable accounts without orders
   * 
   * @param orders : list of orders deleted to check account if has no orders and disabled it
   */
  public static void disableAccountsWithoutOrders(List<Order> orders) {
    // List of accounts to check
    Set<Id> accountIds = new Set<Id>();

    // For each order, check if associate account has order
    for (Order order : orders) {
      accountIds.add(order.AccountId);
    }

    // Update accounts without Orders
    AccountService.disableAccountsWithoutOrders(accountIds);
  }
}