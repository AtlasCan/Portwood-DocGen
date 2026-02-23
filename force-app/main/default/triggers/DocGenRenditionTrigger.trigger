trigger DocGenRenditionTrigger on DocGen_Rendition_Event__e (after insert) {
    List<Id> cvIds = new List<Id>();
    for (DocGen_Rendition_Event__e event : Trigger.new) {
        cvIds.add((Id)event.Source_CV_Id__c);
    }
    
    if (!cvIds.isEmpty()) {
        // Since we are in the "Automated Process" context, we have full callout and NC access.
        System.enqueueJob(new DocGenRenditionQueueable(cvIds));
    }
}
