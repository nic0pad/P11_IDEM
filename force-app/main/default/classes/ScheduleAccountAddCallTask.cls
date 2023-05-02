/**
 * Shedule Class to run the batch AccountAddCallTaskBatch
 * Add call task for each accounts without order
 * 
 * @author Nicolas Padiou
 */
global class ScheduleAccountAddCallTask implements Schedulable {
  global void execute(SchedulableContext ctx) {
    AccountAddCallTaskBatch batch = new AccountAddCallTaskBatch();
    Database.executeBatch(batch);
  }
}