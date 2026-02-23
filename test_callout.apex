Id cvId = [SELECT Id FROM ContentVersion WHERE FileType = 'WORD_X' ORDER BY CreatedDate DESC LIMIT 1].Id;
try {
    DocGenRenditionService.capturePdfRendition(cvId);
    System.debug('SUCCESS');
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}
