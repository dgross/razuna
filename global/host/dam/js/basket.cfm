<cfoutput>
<script language="javascript" type="text/javascript">
	// Popup windows for email
	function basketemail(email){
		// Open email Window
		showwindow('#myself#c.basket_email_form&email=' + email,'#JSStringFormat(defaultsObj.trans("send_with_email"))#',600,1);
		// Submit art values
		storevalues();
	}
	// Popup windows for FTP
	function basketftp(){
		// Open email Window
		showwindow('#myself#c.basket_ftp_form','#JSStringFormat(defaultsObj.trans("send_basket_ftp"))#',600,1);
		// Submit art values
		storevalues();
	}
	// Popup windows for Saving Basket
	function basketsave(){
		// Open email Window
		showwindow('#myself#c.basket_save','#JSStringFormat(defaultsObj.trans("save_basket"))#',600,1);
		// Submit art values
		storevalues();
	}
</script>
</cfoutput>