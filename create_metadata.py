import os

base_dir = '/Users/davemoudy/Projects/Portwood Global/Document Generation/force-app/main/default/objects'

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content.strip())

# Object 1: DocGen_Signature_Request__c
req_dir = os.path.join(base_dir, 'DocGen_Signature_Request__c')
write_file(os.path.join(req_dir, 'DocGen_Signature_Request__c.object-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <deploymentStatus>Deployed</deploymentStatus>
    <enableActivities>true</enableActivities>
    <enableBulkApi>true</enableBulkApi>
    <enableFeeds>false</enableFeeds>
    <enableHistory>true</enableHistory>
    <enableReports>true</enableReports>
    <enableSearch>true</enableSearch>
    <enableSharing>true</enableSharing>
    <enableStreamingApi>true</enableStreamingApi>
    <label>DocGen Signature Request</label>
    <nameField>
        <displayFormat>SIG-{000000}</displayFormat>
        <label>Request Number</label>
        <type>AutoNumber</type>
    </nameField>
    <pluralLabel>DocGen Signature Requests</pluralLabel>
    <sharingModel>ReadWrite</sharingModel>
</CustomObject>
""")

write_file(os.path.join(req_dir, 'fields', 'Signer_Email__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Signer_Email__c</fullName>
    <externalId>false</externalId>
    <label>Signer Email</label>
    <required>false</required>
    <trackHistory>false</trackHistory>
    <type>Email</type>
    <unique>false</unique>
</CustomField>
""")

write_file(os.path.join(req_dir, 'fields', 'Signer_Name__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Signer_Name__c</fullName>
    <externalId>false</externalId>
    <label>Signer Name</label>
    <length>255</length>
    <required>false</required>
    <trackHistory>false</trackHistory>
    <type>Text</type>
    <unique>false</unique>
</CustomField>
""")

write_file(os.path.join(req_dir, 'fields', 'Source_Document_Id__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Source_Document_Id__c</fullName>
    <description>The ID of the ContentDocument to be signed.</description>
    <externalId>false</externalId>
    <label>Source Document Id</label>
    <length>18</length>
    <required>false</required>
    <trackHistory>false</trackHistory>
    <type>Text</type>
    <unique>false</unique>
</CustomField>
""")

write_file(os.path.join(req_dir, 'fields', 'Secure_Token__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Secure_Token__c</fullName>
    <externalId>true</externalId>
    <label>Secure Token</label>
    <length>255</length>
    <required>false</required>
    <trackHistory>false</trackHistory>
    <type>Text</type>
    <unique>true</unique>
</CustomField>
""")

write_file(os.path.join(req_dir, 'fields', 'Status__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Status__c</fullName>
    <externalId>false</externalId>
    <label>Status</label>
    <required>false</required>
    <trackHistory>true</trackHistory>
    <type>Picklist</type>
    <valueSet>
        <restricted>true</restricted>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <fullName>Draft</fullName>
                <default>true</default>
                <label>Draft</label>
            </value>
            <value>
                <fullName>Sent</fullName>
                <default>false</default>
                <label>Sent</label>
            </value>
            <value>
                <fullName>Viewed</fullName>
                <default>false</default>
                <label>Viewed</label>
            </value>
            <value>
                <fullName>Signed</fullName>
                <default>false</default>
                <label>Signed</label>
            </value>
            <value>
                <fullName>Cancelled</fullName>
                <default>false</default>
                <label>Cancelled</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
""")

# Object 2: DocGen_Signature_Audit__c
aud_dir = os.path.join(base_dir, 'DocGen_Signature_Audit__c')
write_file(os.path.join(aud_dir, 'DocGen_Signature_Audit__c.object-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <deploymentStatus>Deployed</deploymentStatus>
    <enableActivities>false</enableActivities>
    <enableBulkApi>true</enableBulkApi>
    <enableFeeds>false</enableFeeds>
    <enableHistory>false</enableHistory>
    <enableReports>true</enableReports>
    <enableSearch>true</enableSearch>
    <enableSharing>true</enableSharing>
    <enableStreamingApi>true</enableStreamingApi>
    <label>DocGen Signature Audit</label>
    <nameField>
        <displayFormat>AUD-{000000}</displayFormat>
        <label>Audit Number</label>
        <type>AutoNumber</type>
    </nameField>
    <pluralLabel>DocGen Signature Audits</pluralLabel>
    <sharingModel>ControlledByParent</sharingModel>
</CustomObject>
""")

write_file(os.path.join(aud_dir, 'fields', 'Signature_Request__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Signature_Request__c</fullName>
    <externalId>false</externalId>
    <label>Signature Request</label>
    <referenceTo>DocGen_Signature_Request__c</referenceTo>
    <relationshipLabel>Audits</relationshipLabel>
    <relationshipName>Audits</relationshipName>
    <relationshipOrder>0</relationshipOrder>
    <reparentableMasterDetail>false</reparentableMasterDetail>
    <type>MasterDetail</type>
    <writeRequiresMasterRead>false</writeRequiresMasterRead>
</CustomField>
""")

write_file(os.path.join(aud_dir, 'fields', 'IP_Address__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>IP_Address__c</fullName>
    <externalId>false</externalId>
    <label>IP Address</label>
    <length>45</length>
    <required>false</required>
    <type>Text</type>
    <unique>false</unique>
</CustomField>
""")

write_file(os.path.join(aud_dir, 'fields', 'User_Agent__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>User_Agent__c</fullName>
    <externalId>false</externalId>
    <label>User Agent</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
    <unique>false</unique>
</CustomField>
""")

write_file(os.path.join(aud_dir, 'fields', 'Signed_Date__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Signed_Date__c</fullName>
    <externalId>false</externalId>
    <label>Signed Date</label>
    <required>false</required>
    <type>DateTime</type>
</CustomField>
""")

write_file(os.path.join(aud_dir, 'fields', 'Document_Hash_SHA256__c.field-meta.xml'), """
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Document_Hash_SHA256__c</fullName>
    <externalId>false</externalId>
    <label>Document Hash (SHA-256)</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
    <unique>false</unique>
</CustomField>
""")
print("Created metadata files successfully.")
