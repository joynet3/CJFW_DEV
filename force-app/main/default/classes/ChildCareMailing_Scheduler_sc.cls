global class ChildCareMailing_Scheduler_sc implements Schedulable, Database.AllowsCallouts {

    public void execute(SchedulableContext sc) {
        ChildCareMailing_ba ba = new ChildCareMailing_ba();
        Database.executeBatch(ba);
    }

}