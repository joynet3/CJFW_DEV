trigger QuoteLineItem on QuoteLineItem(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new QuoteLineItem_tr().run();
}