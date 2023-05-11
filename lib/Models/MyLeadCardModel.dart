class MyLeadCartModel {
  String? leadId;
  String? name;
  String? contact;
  String? sourceLead;
  String? status;
  String? timeStamp;
  String? product;
  String? modifyDays;
  String? createdBy;

  MyLeadCartModel(
      {this.leadId,
        this.name,
        this.contact,
        this.sourceLead,
        this.status,
        this.timeStamp,
        this.product,
        this.createdBy});

  MyLeadCartModel.fromJson(Map<String?, dynamic> json) {
    leadId = json['leadId'];
    name = json['name'];
    contact = json['contact'];
    sourceLead = json['sourceLead'];
    status = json['status'];
    timeStamp = json['timeStamp'];
    product = json['product'];
    createdBy = json['createdBy'];

  }

  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = new Map<String?, dynamic>();
    data['leadId'] = this.leadId;
    data['name'] = this.name;
    data['contact'] = this.contact;
    data['sourceLead'] = this.sourceLead;
    data['status'] = this.status;
    data['timeStamp'] = this.timeStamp;
    data['product'] = this.product;
    data['createdBy'] = this.createdBy;

    return data;
  }
}
