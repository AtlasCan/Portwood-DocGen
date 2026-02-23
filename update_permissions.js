const fs = require('fs');

function updatePerms(file, isAdmin) {
    let xml = fs.readFileSync(file, 'utf8');
    
    // Add Object Permissions
    const objReq = `
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>${isAdmin}</modifyAllRecords>
        <object>DocGen_Signature_Request__c</object>
        <viewAllFields>false</viewAllFields>
        <viewAllRecords>${isAdmin}</viewAllRecords>
    </objectPermissions>`;
    
    const objAud = `
    <objectPermissions>
        <allowCreate>${isAdmin}</allowCreate>
        <allowDelete>${isAdmin}</allowDelete>
        <allowEdit>${isAdmin}</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>${isAdmin}</modifyAllRecords>
        <object>DocGen_Signature_Audit__c</object>
        <viewAllFields>false</viewAllFields>
        <viewAllRecords>${isAdmin}</viewAllRecords>
    </objectPermissions>`;

    // Add Field Permissions
    let fields = '';
    ['Signer_Email__c', 'Signer_Name__c', 'Source_Document_Id__c', 'Secure_Token__c', 'Status__c'].forEach(f => {
        fields += `
    <fieldPermissions>
        <editable>true</editable>
        <field>DocGen_Signature_Request__c.${f}</field>
        <readable>true</readable>
    </fieldPermissions>`;
    });

    ['IP_Address__c', 'User_Agent__c', 'Signed_Date__c', 'Document_Hash_SHA256__c'].forEach(f => {
        fields += `
    <fieldPermissions>
        <editable>${isAdmin}</editable>
        <field>DocGen_Signature_Audit__c.${f}</field>
        <readable>true</readable>
    </fieldPermissions>`;
    });

    const tabs = `
    <tabSettings>
        <tab>DocGen_Signature_Request__c</tab>
        <visibility>Visible</visibility>
    </tabSettings>
    <tabSettings>
        <tab>DocGen_Signature_Audit__c</tab>
        <visibility>Visible</visibility>
    </tabSettings>`;

    // Insert before </PermissionSet>
    xml = xml.replace('</PermissionSet>', objReq + objAud + fields + tabs + '\n</PermissionSet>');
    fs.writeFileSync(file, xml);
}

updatePerms('force-app/main/default/permissionsets/DocGen_Admin.permissionset-meta.xml', 'true');
updatePerms('force-app/main/default/permissionsets/DocGen_User.permissionset-meta.xml', 'false');
console.log('Done');
