trigger OrderTrigger on Order (before update) {
  if (Trigger.isUpdate && Trigger.isBefore) {
    for(Order o: Trigger.new) {
      if(!OrderService.canSaved(o, Trigger.oldMap.get(o.Id))){
        o.addError('Add products to activate order !');
      }
    }
  }
}