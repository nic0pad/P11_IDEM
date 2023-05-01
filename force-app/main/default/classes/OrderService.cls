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

  public static Boolean canSaved(Order newOrder, Order oldOrder) {
    if (newOrder.Status != 'Activated') {
      return true;
    }
    if(OrderService.hasActivated(newOrder.Status, oldOrder.Status) == true && OrderService.getNumberOfOrderItems(newOrder.Id) > 0) {
      return true;
    }
    return false;
  }

  public static Boolean hasActivated(String newStatus, String oldStatus) {
    if(newStatus == 'Activated' && newStatus != oldStatus) {
      return true;
    }
    return false;
  }
}