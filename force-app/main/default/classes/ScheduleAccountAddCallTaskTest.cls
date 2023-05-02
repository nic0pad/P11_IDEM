@isTest
private class ScheduleAccountAddCallTaskTest {
  // Dummy CRON expression: midnight on March 15.
  // Because this is a test, job executes
  // immediately after Test.stopTest().
  public static String CRON_EXP = '0 0 0 15 3 ? 2024';
  @isTest static void test() {
    // Verify that AsyncApexJob is empty
    // not strictly necessary but makes what is going on later clearer
    List<AsyncApexJob> jobsBefore = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob];
    System.assertEquals(0, jobsBefore.size(), 'not expecting any asyncjobs');

    Test.startTest();
    // Schedule the test job
    String jobId = System.schedule('ScheduleTest', ScheduleAccountAddCallTaskTest.CRON_EXP, new ScheduleAccountAddCallTask());

    // Get the information from the CronTrigger API object
    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

    // Verify the expressions are the same
    System.assertEquals(ScheduleAccountAddCallTaskTest.CRON_EXP, ct.CronExpression);

    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered);

    // Verify the next time the job will run
    System.assertEquals('2024-03-15 00:00:00', String.valueOf(ct.NextFireTime));

    Test.stopTest();

    // There will now be two things in AsyncApexJob - the Schedulable itself
    // and also the Batch Apex job. This code looks for both of them

    // Check schedulable is in the job list
    List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
    System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
    System.assertEquals('ScheduleAccountAddCallTask', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');

    // check apex batch is in the job list
    List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
    System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
    System.assertEquals('AccountAddCallTaskBatch', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');
  }
}