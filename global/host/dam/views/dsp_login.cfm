<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<!--- 
Page output starts here
 --->
<cfoutput>
<div id="login_div">
	<span class="loginform_header">
		<cfif fileexists("#ExpandPath("../..")#global/host/logo/#session.hostid#/logo.jpg")>
			<img src="#dynpath#/global/host/logo/#session.hostid#/logo.jpg" border="0" />
		<cfelse>
			<img src="#dynpath#/global/host/dam/images/razuna_logo-200.png" width="200" height="29" border="0" style="padding:3px 0px 0px 5px;">
		</cfif>
	</span>
	<cfif nohost EQ "F">
	<br />
	<span class="loginform_header">#defaultsObj.trans("headerlogin")#</span>
	<br />
	<br />
	<div id="login_feedback">
	<form action="//#cgi.http_host##self#" method="post" name="form_login" id="form_login">
	<input type="hidden" name="#theaction#" value="#xfa.submitform#">
	<input type="hidden" name="tl" value="t">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	    <tr>
	        <td width="100%" nowrap>#defaultsObj.trans("username")#</td>
		</tr>
		<tr>
			<td width="100%" nowrap style="padding-bottom:10px;">
				<label for="name" class="error" style="display:none;">Enter a username!</label>
				<cfif structkeyexists(url,"email")>
					<cfset loginvalue = url.email>
				<cfelse>
					<cfset loginvalue = cookie.loginname>
				</cfif>
	       	 	<div id="login_name"><input type="text" name="name" id="name" style="width:250px;" value="#loginvalue#" /></div>
			</td>
	    </tr>
	    <tr>
	        <td>#defaultsObj.trans("password")#</td>
		</tr>
		<tr>
	        <td style="padding-bottom:10px;">
		        <label for="pass" class="error" style="display:none;">Enter a password!</label>
		    	<div id="login_password"><input type="password" name="pass" id="pass" style="width:250px;" value="#cookie.loginpass#" /></div>
			</td>
	    </tr>
	    <tr>
			<td><input type="checkbox" name="rem_login" id="rem_login" value="T"<cfif structkeyexists(cookie,"loginrem") AND cookie.loginrem EQ "t"> checked="checked"</cfif>> <a href="##" onclick="clickcbk('form_login','rem_login',0);return false;" style="color:##000000;text-decoration:none;">#defaultsObj.trans("remember_login")#</a></td>
		</tr>
	    <tr>
	        <td align="right" style="padding-bottom:10px;padding-top:10px;"><input type="submit" name="submitbutton" value="#defaultsObj.trans("button_login")#" class="button" /></td>
	    </tr>
		<cfif qry_langs.recordcount NEQ 1>
			<tr>
		        <td align="right" style="padding-bottom:10px;">
					<select name="app_lang" onChange="javascript:changelang('form_login');">
						<option value="javascript:void();" selected>#defaultsObj.trans("changelang")#</option>
						<cfloop query="qry_langs">
						<option value="#myself##xfa.switchlang#&to=index&thelang=#lang_name#">#lang_name#</option>
						</cfloop>
					</select>
				</td>
		    </tr>
		</cfif>
		<!--- Show switch link to default language if only one language is set and it is not english --->
		<cfif qry_langs.recordcount EQ 1 and session.thelangid NEQ qry_langs.lang_id>
			<tr>
		        <td align="right" style="padding-bottom:10px;">Your Administrator set Razuna to #qry_langs.lang_name#, but your current language is #ucase(left(session.thelang,1))##mid(session.thelang,2,20)#.<br />Do you want to <a href="#myself##xfa.switchlang#&to=index&thelang=#qry_langs.lang_name#">switch to #qry_langs.lang_name#</a> now?</td>
		    </tr>
		</cfif>
	    <tr>
			<td align="right" nowrap="true"><a href="##" onclick="loadcontent('login_div','#myself##xfa.forgotpass#');$('##alertbox').html('');return false;">#defaultsObj.trans("forgot_password")#</a></td>
		</tr>
		<tr>
			<td align="right" nowrap="true"><a href="##" onclick="loadcontent('login_div','#myself##xfa.req_access#');$('##alertbox').html('');return false;">#defaultsObj.trans("request_access")#</a></td>
		</tr>
	</table>
	</form>
	</div>
	<cfelse>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	    <tr>
	        <td width="100%">We could not find a host under this domain. If you want to create a Hosted Razuna account, then please go to <a href="http://razuna.com">http://razuna.com</a>.</td>
		</tr>
	</table>
	</cfif>
	<cfif attributes.loginerror EQ "T">
		<div id="alertbox" style="padding-top:10px;" class="alert">#defaultsObj.trans("login_error")#</div>
	</cfif>
</div>
<div id="login_loading"></div>
<!--- <div id="alertbox" style="padding-top:10px;display:none;" class="alert">#defaultsObj.trans("login_error")#</div> --->
</cfoutput>

<script type="text/javascript">
	$('#name').focus();
</script>