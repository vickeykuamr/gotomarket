class LeadDetailsModel {
  String? leadId;
  String? name;
  String? email;
  String? contactNo;
  String? alternateNo;
  String? address;
  String? state;
  String? leadSource;
  String? companyName;
  String? leadquality;
  String? website;
  String? industryType;
  String? leadStatus;
  String? statusReason;
  String? assignedAgent;
  String? timestamp;
  String? product;
  String? description;
  String? sourcename;
  String? message;
  String? createdBy;
  String? expectedCloseDate;
  String? salesStage;
  String? amount;
  var comment;
  var eventDetails;

  LeadDetailsModel(
      {this.leadId,
        this.name,
        this.email,
        this.contactNo,
        this.alternateNo,
        this.address,
        this.state,
        this.leadSource,
        this.companyName,
        this.leadquality,
        this.website,
        this.industryType,
        this.leadStatus,
        this.statusReason,
        this.assignedAgent,
        this.timestamp,
        this.product,
        this.description,
        this.sourcename,
        this.message,
        this.createdBy,
        this.expectedCloseDate,
        this.salesStage,
        this.amount,
        this.comment});

  LeadDetailsModel.fromJson(Map<String, dynamic> json) {
    leadId = json['leadId'];
    name = json['name'];
    email = json['email'];
    contactNo = json['contactNo'];
    alternateNo = json['alternateNo'];
    address = json['address'];
    state = json['state'];
    leadSource = json['leadSource'];
    companyName = json['companyName'];
    leadquality = json['leadquality'];
    website = json['website'];
    industryType = json['industryType'];
    leadStatus = json['leadStatus'];
    statusReason = json['statusReason'];
    assignedAgent = json['assignedAgent'];
    timestamp = json['timestamp'];
    product = json['product'];
    description = json['description'];
    sourcename = json['sourcename'];
    message = json['message'];
    createdBy = json['createdBy'];
    expectedCloseDate = json['expected_close_date'];
    salesStage = json['sales_stage'];
    amount = json['amount'];
    comment = json['comment'];
    eventDetails = json['event_details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['leadId'] = this.leadId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['contactNo'] = this.contactNo;
    data['alternateNo'] = this.alternateNo;
    data['address'] = this.address;
    data['state'] = this.state;
    data['leadSource'] = this.leadSource;
    data['companyName'] = this.companyName;
    data['leadquality'] = this.leadquality;
    data['website'] = this.website;
    data['industryType'] = this.industryType;
    data['leadStatus'] = this.leadStatus;
    data['statusReason'] = this.statusReason;
    data['assignedAgent'] = this.assignedAgent;
    data['timestamp'] = this.timestamp;
    data['product'] = this.product;
    data['description'] = this.description;
    data['sourcename'] = this.sourcename;
    data['message'] = this.message;
    data['createdBy'] = this.createdBy;
    data['expected_close_date'] = this.expectedCloseDate;
    data['sales_stage'] = this.salesStage;
    data['amount'] = this.amount;
    data['comment'] = this.comment;
    data['event_details'] = this.eventDetails;
    return data;
  }
}
