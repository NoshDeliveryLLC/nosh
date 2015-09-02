
var Stripe = require('stripe');
Stripe.initialize('sk_live_FL3MO6tfnQFcQOjr7ntCsdwU'); 
 
Parse.Cloud.define("pay", function(request, response) {
    if(request.params.amount && request.params.tokenId){

        Stripe.Charges.create({
        	amount: request.params.amount * 100,
        	currency: "usd",
        	card: request.params.tokenId,
		metadata: request.params.metadata

    	},{
    	success: function(httpResponse) {
            response.success(httpResponse);
    	},
    	error: function(httpResponse) {
	    if(httpResponse["name"] == "card_error"){
		response.error(httpResponse["message"]);
	    } else {
            	response.error("Uh oh, something went wrong");
            }
    	}
   });
    
} else {
    response.error("Invalid params");
}
});

Parse.Cloud.define("refund", function(request, response) {
    if(request.params.chargeId){
 
    Parse.Config.get().then(function(config) {
        Stripe.Charges.refund(request.params.chargeId, request.params.amount * 100, {
    	success: function(httpResponse) {
            response.success(httpResponse);
    	},
    	error: function(httpResponse) {
            response.error("Uh oh, something went wrong");
    	}
   });
    });
    
} else {
    response.error("Invalid params");
}
});
 
var Mailgun = require('mailgun');
 
function sendMail(to, subject, text, config, response){
    if(to && to != ""){
	Mailgun.initialize(config.get('mailgun_domain'), config.get('mailgun_key'));
    	Mailgun.sendEmail({
            to: to,
	    bcc: config.get('support_email'),
            from: config.get('from_email_address'),
            subject: subject,
            text: text
    	}, {
    	    success: function(httpResponse) {
		if(response){
            	    response.success("Email sent! "+to);
		}		
    	    },
    	    error: function(httpResponse) {
		if(response){
            	    response.error(httpResponse);
		}
    	    }
     	});
	
    } else {
    	if(response){
	    response.error("Invalid email");
	}
    }
}
 
function getOrderSummary(order, orderItems){
    var summary = "";
    for(var i in orderItems){
	var orderItem = orderItems[i];
	summary += orderItem.get("title") + "\t" + orderItem.get("count") + " x $" + orderItem.get("price") + "\n";
    }
    summary += "\nSub Total\t\t\t= $" + order.get("subTotal");
    summary += "\nTax\t\t\t\t= $" + order.get("tax");
    summary += "\nService Charges\t= $" + order.get("serviceCharges");
    summary += "\n\nTotal\t\t\t= $" + order.get("totalAmount");

    if(order.get("notes")){
    	summary += "\n\nNotes \"" + order.get("notes")+"\"";
    }

    return summary;
}

Parse.Cloud.define("sendNewOrderMail", function(request, response) {
    var query = new Parse.Query("Order");
    query.include("vendor");
    query.include("user");
    query.get(request.params.orderId, {
    success: function(order) {
    	var relation = order.relation("items");
    	var query = relation.query();
    	query.find({
       	    success : function(orderItems) {

		Parse.Config.get().then(function(config) {
		    Parse.Cloud.httpRequest({ url: config.get('new_order_deliverer_template').url() }).then(function(data) {
			query = new Parse.Query("User");
			query.exists("email");
			var userRole = new Parse.Role();
			userRole.id = "h2VHyIvUTs";
			query.equalTo("userRole", userRole)
			query.find({
       	    	    	    success : function(users) {
				for(var i in users){
				    var deliverer = users[i];
				    var text = replaceTemplates(data.text, order, orderItems, config, deliverer);
				    sendMail(deliverer.get("email"), config.get('new_order_deliverer_subject'), text, config);
				}
			    }
		    	});
		    });

		    Parse.Cloud.httpRequest({ url: config.get('new_order_user_template').url() }).then(function(data) {
			var text = replaceTemplates(data.text, order, orderItems, config);
			sendMail(order.get("user").get("email"), config.get('new_order_user_subject'), text, config);
		    });	

		    Parse.Cloud.httpRequest({ url: config.get('new_order_vendor_template').url() }).then(function(data) {
			var text = replaceTemplates(data.text, order, orderItems, config);
			sendMail(order.get("vendor").get("email"), config.get('new_order_vendor_subject'), text, config, response);
		    });	

		});			
	    },
	    error : function(error) {
          	response.error(error);
       	    }
    	});
    },
    error: function(object, error) {
        response.error(error);
    }
    });
 
});

String.prototype.replaceAll = function (find, replace) {
    var str = this;
    return str.replace(new RegExp(find.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'g'), replace);
};

function replaceTemplates(text, order, orderItems, config, deliverer){
    text = text.replaceAll("${ordering_person_name}", order.get("user").get("name"))
	.replaceAll("${order_number}", order.id)
	.replaceAll("${order_date_time}", order.createdAt)
	.replaceAll("${ordering_person_address}", getAddress(order.get("user")))
	.replaceAll("${ordering_person_phone}", order.get("user").get("phone"))
	.replaceAll("${vendor_name}", order.get("vendor").get("name"))
	.replaceAll("${vendor_address}", getAddress(order.get("vendor")))
	.replaceAll("${vendor_phone}", order.get("vendor").get("phone"))
	.replaceAll("${support_email}", config.get("support_email"))
	.replaceAll("${support_phone}", config.get("support_phone"));
  	
    if(orderItems){
	text = text.replaceAll("${order_summary}", getOrderSummary(order, orderItems));
    }

    if(deliverer){
	text = text.replaceAll("${deliverer_name}", deliverer.get("name"))
		.replaceAll("${deliverer_phone}", deliverer.get("phone"));
    }
    return text;
}

function getAddress(object){
    var address = "";
    if(object.get("addressLine1")){
 	address += object.get("addressLine1");
    }
//    if(object.get("addressLine2")){
//	address += " "+object.get("addressLine2");
//    }
//    if(object.get("city")){
//       	address += ". "+object.get("city");
//    }
//    if(object.get("state")){
//     	address += ", "+object.get("state");
//    }
//    if(object.get("zip")){
//    	address += " "+object.get("zip");
//    }
    return address;
}

Parse.Cloud.define("sendOrderStatusChangedMail", function(request, response) {
    response.success("Email sent!");
});
 
Parse.Cloud.define("sendOrderAcceptedMail", function(request, response) {
    var query = new Parse.Query("Order");
    query.include("vendor");
    query.include("user");
    query.include("assignedTo")
    query.get(request.params.orderId, {
    success: function(order) {  	
	if(order.get("assignedTo")){
	    Parse.Config.get().then(function(config) {
	    	Parse.Cloud.httpRequest({ url: config.get('order_accepted_user_template').url() }).then(function(data) {
		    var text = replaceTemplates(data.text, order, null, config, order.get("assignedTo"));
		    sendMail(order.get("user").get("email"), config.get('order_accepted_user_subject'), text, config, response);
	    	});
	    });
	} else {
	    response.error("Order not assigned to anyone");
	}  
    },
    error: function(object, error) {
        response.error(error);
    }
    });
});

Parse.Cloud.define("NewOrder", function(request) {
    
Parse.Push.send({
  channels: ["Deliverer"],
  data: {
    alert: "New delivery job is available from " + request.params.name,
    badge: "Increment"
  }
}, {
  success: function() {
    // Push was successful
  },
  error: function(error) {
    // Handle error
  }
 });
});