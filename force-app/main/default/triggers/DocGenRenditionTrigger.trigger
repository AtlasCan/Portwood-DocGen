trigger DocGenRenditionTrigger on DocGen_Rendition_Event__e (after insert) {
    Map<Id, Id> cvIdToRecordId = new Map<Id, Id>();
    for (DocGen_Rendition_Event__e event : Trigger.new) {
        if (event.Source_CV_Id__c != null) {
            cvIdToRecordId.put((Id)event.Source_CV_Id__c, (Id)event.Related_Record_Id__c);
        }
    }
    
    if (!cvIdToRecordId.isEmpty()) {
        System.enqueueJob(new DocGenRenditionQueueable(cvIdToRecordId));
    }
}