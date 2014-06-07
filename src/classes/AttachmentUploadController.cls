public with sharing class AttachmentUploadController {

    public Account account {get;set;}
    //public List<Attachment> attachmentList{get;set;}

/*
//test
    public AttachmentUploadController (ApexPages.StandardController c) {

        this.attachmentList = getAttachmentList((String)c.getRecord().get('id'));
        //attachmentを並び替えのため取得する
        this.account = getAccount((String)c.getRecord().get('id'));

    }
*/

    public AttachmentUploadController () {
        //Accuntとattachmentを並び替えのため取得する
        this.account = getAccount(ApexPages.currentPage().getParameters().get('id'));
     }

    @RemoteAction
    public static String doUploadAttachment(String acctId, String attachmentBody, String attachmentName, String attachmentId,String comment) {
        //idがある場合
        if(acctId != null) {
            Account acct = getAccount(acctId);
            if(acct != null) {
                if(attachmentBody != null) {
                    Attachment att = getAttachment(attachmentId);
                    String newBody = '';
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += attachmentBody;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    if(attachmentId == null) {
                        att.Name = attachmentName;
                        att.parentId = acct.Id;
                        att.Description = comment;
                    }
                    upsert att;
                    return att.Id;
                } else {
                    return 'Attachment Body was null';
                }
            } else {
                return 'Account could not be found';
            }
        } else {
            return 'Account Id was null';
        }
    }

    @RemoteAction
    public static String doSubmitForm(String acctId, String description, String website, String phone) {
        if(acctId != null) {
            Account acct = getAccount(acctId);
            if(acct != null) {
                acct.Description = description;
                acct.Website = website;
                acct.Phone = phone;
                update acct;
                return 'Success';
            } else {
                return 'Account could not be found';
            }
        } else {
            return 'Account Id was null';
        }
    }
    /**
     * Account取得
    */
    private static Account getAccount(String acctId) {
        list<Account> accounts = [
            SELECT
                Id,
                Name
                ,(select
                    id
                    ,title
                    ,IsNote
                    ,LastModifiedDate
                from NotesAndAttachments order by LastModifiedDate desc)
            FROM
                Account
            WHERE Id =: acctId
        ];
        if(accounts.isEmpty()) {
            return null;
        } else {
            return accounts[0];
        }
    }

    /**
     * Attachment取得
    */
    private static Attachment getAttachment(String attId) {
        List<Attachment> attachments = [
            SELECT
                Id,
                Body
            FROM
                Attachment
            WHERE
                Id =: attId
            ];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }

/*
    private static List<Attachment> getAttachmentList(String accountid) {
        List<Attachment> attachments = [
            SELECT
                Id
                ,Body
                ,name
                ,ContentType
                ,LastModifiedDate
                ,Description
            FROM
                Attachment
            WHERE
                ParentId =: accountid
            order by lastmodifieddate desc
            ];
        return attachments;
    }
    */
}