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
<cfcomponent output="false" extends="authentication">
	
	<!--- Retrieve assets from a folder --->
	<cffunction name="searchassets" access="remote" output="false" returntype="query" returnformat="json">
		<cfargument name="api_key" type="string" required="true">
		<cfargument name="searchfor" type="string" required="true">
		<cfargument name="show" type="string" required="false" default="all">
		<cfargument name="doctype" type="string" required="false" default="">
		<cfargument name="datecreate" type="string" required="false" default="">
		<cfargument name="datechange" type="string" required="false" default="">
		<cfargument name="folderid" type="string" required="false" default="0">
		<cfargument name="datecreateparam" type="string" required="false" default="">
		<cfargument name="datecreatestart" type="string" required="false" default="">
		<cfargument name="datecreatestop" type="string" required="false" default="">
		<cfargument name="datechangeparam" type="string" required="false" default="">
		<cfargument name="datechangestart" type="string" required="false" default="">
		<cfargument name="datechangestop" type="string" required="false" default="">
		<cfargument name="sortby" type="string" required="false" default="name">
		<cfargument name="ui" type="string" required="false" default="false">
		<!--- Check key --->
		<cfset var thesession = checkdb(arguments.api_key)>
		<!--- Check to see if session is valid --->
		<cfif thesession>
			<!--- Set sessions --->
			<cfset session.listimgid = "">
			<cfset session.listvidid = "">
			<cfset session.listaudid = "">
			<cfset session.listdocid = "">
			<!--- Set the sortby session --->
			<cfset session.sortby = arguments.sortby>
			<!--- Images --->
			<cfif arguments.show EQ "ALL" OR arguments.show EQ "img">
				<!--- Call search function --->
				<cfset var qimg = search_images(arguments)>
				<!--- for the UI --->
				<cfset session.listimgid = valueList(qimg.id)>
			</cfif>
			<!--- Videos --->
			<cfif arguments.show EQ "ALL" OR arguments.show EQ "vid">
				<!--- Call search function --->
				<cfset var qvid = search_videos(arguments)>
				<!--- for the UI --->
				<cfset session.listvidid = valueList(qvid.id)>
			</cfif>
			<!--- Audios --->
			<cfif arguments.show EQ "ALL" OR arguments.show EQ "aud">
				<!--- Call search function --->
				<cfset var qaud = search_audios(arguments)>
				<!--- for the UI --->
				<cfset session.listaudid = valueList(qvid.id)>
			</cfif>
			<!--- Doc --->
			<cfif arguments.show EQ "ALL" OR arguments.show EQ "doc">
				<!--- Call search function --->
				<cfset var qdoc = search_files(arguments)>
				<!--- for the UI --->
				<cfset session.listdocid = valueList(qvid.id)>
			</cfif>
			<!--- Add our own tags to the query --->
			<cfset var q = querynew("responsecode,totalassetscount,calledwith")>
			<cfset queryaddrow(q,1)>
			<cfset querysetcell(q,"calledwith",arguments.searchfor)>
			<!--- If we SHOW = ALL then we need to cann the combine function --->
			<cfif arguments.show EQ "ALL">
				<!--- Call combine all function --->
				<cfinvoke component="global.cfc.search" method="search_combine" qimg="#qimg#" qvid="#qvid#" qaud="#qaud#" qdoc="#qdoc#" returnvariable="qry_combined">
				<!--- Add the total to our internal one --->
				<cfset querysetcell(q,"totalassetscount",qry_combined.thetotal)>
				<!--- Set var --->
				<cfset var qry = qry_combined.qall>
				<!--- for the UI --->
				<cfset session.thetotal = qry_combined.thetotal>
				<cfset session.qall = qry>
				<cfset session.qimg = qimg.cnt>
				<cfset session.qvid = qvid.cnt>
				<cfset session.qaud = qaud.cnt>
				<cfset session.qdoc = qdoc.cnt>
			<!--- images --->
			<cfelseif arguments.show EQ "img">
				<cfset var qry = qimg>
				<!--- for the UI --->
				<cfset session.thetotal = qimg.cnt>
				<cfset session.qall = qimg>
				<cfset session.qimg = qimg.cnt>
			<!--- videos --->
			<cfelseif arguments.show EQ "vid">
				<cfset var qry = qvid>
				<!--- for the UI --->
				<cfset session.thetotal = qvid.cnt>
				<cfset session.qall = qvid>
				<cfset session.qvid = qvid.cnt>
			<!--- audios --->
			<cfelseif arguments.show EQ "aud">
				<cfset var qry = qaud>
				<!--- for the UI --->
				<cfset session.thetotal = qaud.cnt>
				<cfset session.qall = qaud>
				<cfset session.qaud = qaud.cnt>
			<!--- files --->
			<cfelseif arguments.show EQ "doc">
				<cfset var qry = qdoc>
				<!--- for the UI --->
				<cfset session.thetotal = qdoc.cnt>
				<cfset session.qall = qdoc>
				<cfset session.qdoc = qdoc.cnt>
			</cfif>
			<!--- Set responsecode --->
			<cfif qry.recordcount NEQ 0>
				<cfset var rescode = 0>
			<cfelse>
				<cfset var rescode = 1>
			</cfif>
			<!--- If this is NOT for ALL --->
			<cfif arguments.show NEQ "ALL">
				<cfset querysetcell(q,"totalassetscount",qry.recordcount)>
			</cfif>
			<!--- Set responsecode --->
			<cfset querysetcell(q,"responsecode",rescode)>
			<!--- Put the 2 queries together --->
			<cfquery dbtype="query" name="thexml">
			SELECT *
			FROM qry, q
			</cfquery>
		<!--- No session found --->
		<cfelse>
			<cfset var thexml = timeout()>
		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction>
	
	<!--- Search images --->
	<cffunction name="search_images" access="private" output="false" returntype="query">
		<cfargument name="istruct" required="true">
		<!--- Call date function --->
		<cfset var idate = set_date(datecreate=arguments.istruct.datecreate, datechange=arguments.istruct.datechange)>
		<!--- Search in Lucene --->
		<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.istruct.searchfor#" category="img" hostid="#application.razuna.api.hostid["#arguments.istruct.api_key#"]#" returnvariable="qryluceneimg">
		<!--- If lucene returns no records --->
		<cfif qryluceneimg.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattreeimg">
			SELECT categorytree
			FROM qryluceneimg
			WHERE categorytree != ''
			GROUP BY categorytree
			ORDER BY categorytree
			</cfquery>
		</cfif>
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry_img">
		SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_id as varchar(100)), '0')</cfif> id, 
		i.img_filename filename, 
		i.folder_id_r folder_id, 
		i.img_extension extension, 
		'dummy' as video_image,
		i.img_filename_org filename_org, 
		'img' as kind, 
		i.thumb_extension extension_thumb, 
		i.path_to_asset, 
		i.cloud_url, 
		i.cloud_url_org,
		<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(i.img_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(i.img_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(i.img_size as varchar(100)), '0')</cfif> AS size,
		i.img_width AS width,
		i.img_height AS height,
		it.img_description description, 
		it.img_keywords keywords,
		i.img_create_time dateadd,
		i.img_change_time datechange,
        <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
		    concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.istruct.api_key#"]#/',i.path_to_asset,'/',i.img_filename_org) AS local_url_org,
		    concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.istruct.api_key#"]#/',i.path_to_asset,'/','thumb_',i.img_id,'.',i.thumb_extension) AS local_url_thumb,
        <cfelseif application.razuna.api.thedatabase EQ "mssql">
            'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.istruct.api_key#"]#/' + i.path_to_asset + '/'  + i.img_filename_org AS local_url_org,
            'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.istruct.api_key#"]#/' + i.path_to_asset + '/' + 'thumb_' + i.img_id + '.' + i.thumb_extension AS local_url_thumb,
        </cfif>
    	<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
    		(
    			SELECT GROUP_CONCAT(DISTINCT ic.col_id_r ORDER BY ic.col_id_r SEPARATOR ',') AS col_id
    			FROM #application.razuna.api.prefix["#arguments.istruct.api_key#"]#collections_ct_files ic
    			WHERE ic.file_id_r = i.img_id
    		) AS colid
    	<cfelseif application.razuna.api.thedatabase EQ "mssql">
    		STUFF(
    			(
    				SELECT ', ' + ic.col_id_r
    				FROM #application.razuna.api.prefix["#arguments.istruct.api_key#"]#collections_ct_files ic
    	         	WHERE ic.file_id_r = i.img_id
    	          	FOR XML PATH ('')
              	)
              	, 1, 1, ''
    		) AS colid
    	<cfelseif application.razuna.api.thedatabase EQ "oracle">
    		(
    			SELECT wmsys.wm_concat(ic.col_id_r) AS col_id
    			FROM #application.razuna.api.prefix["#arguments.istruct.api_key#"]#collections_ct_files ic
    			WHERE ic.file_id_r = i.img_id
    		) AS colid
    	</cfif>
    	,
		x.colorspace,
		x.xres AS xdpi,
		x.yres AS ydpi,
		x.resunit AS unit,
		i.hashtag AS md5hash,
		fo.folder_name,
		lower(i.img_filename) filename_forsort
		<!--- for UI --->
		<cfif arguments.istruct.ui>
			,
			i.img_group groupid,
			i.folder_id_r,
			i.thumb_extension ext,
			i.is_available,
			i.img_create_time date_create,
			i.img_change_time date_change,
			i.link_kind, 
			i.link_path_url,
			'0' as vwidth, 
			'0' as vheight,
			i.hashtag,
			'' as labels,
			'#session.customaccess#' as permfolder,
			<cfif application.razuna.api.thedatabase EQ "mssql">i.img_id + '-img'<cfelse>concat(i.img_id,'-img')</cfif> as listid
		</cfif>
		FROM #application.razuna.api.prefix["#arguments.istruct.api_key#"]#images i 
		LEFT JOIN #application.razuna.api.prefix["#arguments.istruct.api_key#"]#images_text it ON i.img_id = it.img_id_r AND it.lang_id_r = 1
		LEFT JOIN #application.razuna.api.prefix["#arguments.istruct.api_key#"]#xmp x ON x.id_r = i.img_id
		LEFT JOIN #application.razuna.api.prefix["#arguments.istruct.api_key#"]#folders fo ON fo.folder_id = i.folder_id_r AND fo.host_id = i.host_id
		WHERE i.img_id IN (<cfif qryluceneimg.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreeimg.categorytree)#" list="Yes"></cfif>)
		AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.istruct.api_key#"]#">
		AND (i.img_group IS NULL OR i.img_group = '')
		<!--- Only if we have dates --->
		<cfif arguments.istruct.datecreate NEQ "">
			<cfif application.razuna.api.thedatabase EQ "mssql">
				AND (DATEPART(yy, i.img_create_time) = idate.the_create_year
				AND DATEPART(mm, i.img_create_time) = idate.the_create_month
				AND DATEPART(dd, i.img_create_time) = idate.the_create_day)
			<cfelse>
				AND i.img_create_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.istruct.datecreate#%">
			</cfif>
		</cfif>
		<cfif arguments.istruct.datechange NEQ "">
			<cfif application.razuna.api.thedatabase EQ "mssql">
				AND (DATEPART(yy, i.img_change_time) = idate.the_change_year
				AND DATEPART(mm, i.img_change_time) = idate.the_change_month
				AND DATEPART(dd, i.img_change_time) = idate.the_change_day)
			<cfelse>
				AND i.img_change_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.istruct.datechange#%">
			</cfif>
		</cfif>
		<cfif arguments.istruct.datecreateparam NEQ "">
			AND i.img_create_time #arguments.istruct.datecreateparam# <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.istruct.datecreatestart#">
			<cfif arguments.istruct.datecreateparam EQ "between">
				AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.istruct.datecreatestop#">
			</cfif>
		</cfif>
		<cfif arguments.istruct.datechangeparam NEQ "">
			AND i.img_change_time #arguments.istruct.datechangeparam# <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.istruct.datechangestart#">
			<cfif arguments.istruct.datechangeparam EQ "between">
				AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.istruct.datechangestop#">
			</cfif>
		</cfif>
		<!--- If we have a folderid --->
		<cfif arguments.istruct.folderid NEQ "" AND arguments.istruct.folderid NEQ 0>
			AND i.folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.istruct.folderid#">
		</cfif>
		GROUP BY i.img_id, i.img_filename, i.folder_id_r, i.img_extension, i.img_filename_org, i.thumb_extension, i.path_to_asset, i.cloud_url, i.cloud_url_org, i.img_size, i.img_width, i.img_height,	i.img_create_time, i.img_change_time, it.img_description, it.img_keywords, colorspace, xdpi, ydpi, unit, md5hash, fo.folder_name, filename_forsort
			<cfif arguments.istruct.ui>, folder_name, folder_id_r, ext, is_available, date_create,
		date_change, link_kind, link_path_url, vwidth, vheight, hashtag, labels, permfolder, listid</cfif>
		ORDER BY filename 
		</cfquery>
		<!--- Add the amount of assets to the query --->
		<cfset var amount = ArrayNew(1)>
		<cfset amount[1] = qry_img.recordcount>
		<cfset QueryAddcolumn(qry_img, "cnt", "integer", amount)>
		<!--- Return --->
		<cfreturn qry_img />
	</cffunction>

	<!--- Search videos --->
	<cffunction name="search_videos" access="private" output="false" returntype="query">
		<cfargument name="vstruct" required="true">
		<!--- Call date function --->
		<cfset var vdate = set_date(datecreate=arguments.vstruct.datecreate, datechange=arguments.vstruct.datechange)>
		<!--- Search in Lucene --->
		<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.vstruct.searchfor#" category="vid" hostid="#application.razuna.api.hostid["#arguments.vstruct.api_key#"]#" returnvariable="qrylucenevid">
		<!--- If lucene returns no records --->
		<cfif qrylucenevid.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattreevid">
			SELECT categorytree
			FROM qrylucenevid
			WHERE categorytree != ''
			GROUP BY categorytree
			ORDER BY categorytree
			</cfquery>
		</cfif>
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry_vid">
		SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(v.vid_id as varchar(100)), '0')</cfif> id, 
		v.vid_filename as filename, 
		v.folder_id_r as folder_id, 
		v.vid_extension as extension, 
		v.vid_name_image as video_image,
		<cfif arguments.vstruct.ui>
			v.vid_name_image as filename_org,
		<cfelse>
			v.vid_name_org as filename_org,
		</cfif>
		'vid' as kind, 
		v.vid_name_image as extension_thumb, 
		v.path_to_asset, 
		v.cloud_url, 
		v.cloud_url_org,
		<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(v.vid_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(v.vid_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(v.vid_size as varchar(100)), '0')</cfif> AS size, 
		v.vid_width AS width,
		v.vid_height AS height,
		vt.vid_description description, 
		vt.vid_keywords keywords,
		v.vid_create_time dateadd,
		v.vid_change_time datechange,
        <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
            concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.vstruct.api_key#"]#/',v.path_to_asset,'/',v.vid_name_org) AS local_url_org,
            concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.vstruct.api_key#"]#/',v.path_to_asset,'/',v.vid_name_image) AS local_url_thumb,
        <cfelseif application.razuna.api.thedatabase EQ "mssql">
            'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.vstruct.api_key#"]#/' + v.path_to_asset + '/' + v.vid_name_org AS local_url_org,
            'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.vstruct.api_key#"]#/' + v.path_to_asset + '/' + v.vid_name_image AS local_url_thumb,
        </cfif>
        <cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
			(
				SELECT GROUP_CONCAT(DISTINCT vc.col_id_r ORDER BY vc.col_id_r SEPARATOR ',') AS col_id
				FROM #application.razuna.api.prefix["#arguments.vstruct.api_key#"]#collections_ct_files vc
				WHERE vc.file_id_r = v.vid_id
			) AS colid
		<cfelseif application.razuna.api.thedatabase EQ "mssql">
			STUFF(
				(
					SELECT ', ' + vc.col_id_r
					FROM #application.razuna.api.prefix["#arguments.vstruct.api_key#"]#collections_ct_files vc
		         	WHERE vc.file_id_r = v.vid_id
		          	FOR XML PATH ('')
	          	)
	          	, 1, 1, ''
			) AS colid
		<cfelseif application.razuna.api.thedatabase EQ "oracle">
			(
				SELECT wmsys.wm_concat(vc.col_id_r) AS col_id
				FROM #application.razuna.api.prefix["#arguments.vstruct.api_key#"]#collections_ct_files vc
				WHERE vc.file_id_r = v.vid_id
			) AS colid
		</cfif>
		,
		'' AS colorspace,
		'' AS xdpi,
		'' AS ydpi,
		'' AS unit,
		v.hashtag AS md5hash,
		fo.folder_name,
		lower(v.vid_filename) filename_forsort
		<!--- for UI --->
		<cfif arguments.vstruct.ui>
			,
			v.vid_group groupid,
			v.folder_id_r,
			v.vid_extension ext,
			v.is_available,
			v.vid_create_time date_create,
			v.vid_change_time date_change,
			v.link_kind, 
			v.link_path_url,
			CAST(v.vid_width AS CHAR) as vwidth, 
			CAST(v.vid_height AS CHAR) as vheight,
			v.hashtag,
			'' as labels,
			'#session.customaccess#' as permfolder,
			<cfif application.razuna.api.thedatabase EQ "mssql">v.vid_id + '-vid'<cfelse>concat(v.vid_id,'-vid')</cfif> as listid
		</cfif>
        FROM #application.razuna.api.prefix["#arguments.vstruct.api_key#"]#videos v 
		LEFT JOIN #application.razuna.api.prefix["#arguments.vstruct.api_key#"]#videos_text vt ON v.vid_id = vt.vid_id_r AND vt.lang_id_r = 1
		LEFT JOIN #application.razuna.api.prefix["#arguments.vstruct.api_key#"]#folders fo ON fo.folder_id = v.folder_id_r AND fo.host_id = v.host_id
		WHERE v.vid_id IN (<cfif qrylucenevid.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreevid.categorytree)#" list="Yes"></cfif>)
		AND (v.vid_group IS NULL OR v.vid_group = '')
		AND v.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.vstruct.api_key#"]#">
		<!--- Only if we have dates --->
		<cfif arguments.vstruct.datecreate NEQ "">
			<cfif application.razuna.api.thedatabase EQ "mssql">
				AND (DATEPART(yy, v.vid_create_time) = vdate.the_create_year
				AND DATEPART(mm, v.vid_create_time) = vdate.the_create_month
				AND DATEPART(dd, v.vid_create_time) = vdate.the_create_day)
			<cfelse>
				AND v.vid_create_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.vstruct.datecreate#%">
			</cfif>
		</cfif>
		<cfif arguments.vstruct.datechange NEQ "">
			<cfif application.razuna.api.thedatabase EQ "mssql">
				AND (DATEPART(yy, v.vid_change_time) = vdate.the_change_year
				AND DATEPART(mm, v.vid_change_time) = vdate.the_change_month
				AND DATEPART(dd, v.vid_change_time) = vdate.the_change_day)
			<cfelse>
				AND v.vid_change_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.vstruct.datechange#%">
			</cfif>
		</cfif>
		<cfif arguments.vstruct.datecreateparam NEQ "">
			AND v.vid_create_time #arguments.vstruct.datecreateparam# <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.vstruct.datecreatestart#">
			<cfif arguments.vstruct.datecreateparam EQ "between">
				AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.vstruct.datecreatestop#">
			</cfif>
		</cfif>
		<cfif arguments.vstruct.datechangeparam NEQ "">
			AND v.vid_change_time #arguments.vstruct.datechangeparam# <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.vstruct.datechangestart#">
			<cfif arguments.vstruct.datechangeparam EQ "between">
				AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.vstruct.datechangestop#">
			</cfif>
		</cfif>
		<!--- If we have a folderid --->
		<cfif arguments.vstruct.folderid NEQ "" AND arguments.vstruct.folderid NEQ 0>
			AND v.folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.vstruct.folderid#">
		</cfif>
		GROUP BY v.vid_id, v.vid_filename, v.folder_id_r, v.vid_extension, v.vid_name_image, v.vid_name_org, v.vid_name_image, v.path_to_asset, v.cloud_url, v.cloud_url_org, v.vid_size, v.vid_width, v.vid_height, vt.vid_description, vt.vid_keywords, v.vid_create_time, v.vid_change_time, colorspace, xdpi, ydpi, unit, md5hash, fo.folder_name, filename_forsort
				<cfif arguments.vstruct.ui>, folder_name, folder_id_r, ext, is_available, date_create,
    		date_change, link_kind, link_path_url, vwidth, vheight, hashtag, labels, permfolder, listid</cfif>
		ORDER BY filename 
		</cfquery>
		<!--- Add the amount of assets to the query --->
		<cfset var amount = ArrayNew(1)>
		<cfset amount[1] = qry_vid.recordcount>
		<cfset QueryAddcolumn(qry_vid, "cnt", "integer", amount)>
		<!--- Return --->
		<cfreturn qry_vid />
	</cffunction>

	<!--- Search audios --->
	<cffunction name="search_audios" access="private" output="false" returntype="query">
		<cfargument name="astruct" required="true">
		<!--- Call date function --->
		<cfset var adate = set_date(datecreate=arguments.astruct.datecreate, datechange=arguments.astruct.datechange)>
		<!--- Search in Lucene --->
		<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.astruct.searchfor#" category="aud" hostid="#application.razuna.api.hostid["#arguments.astruct.api_key#"]#" returnvariable="qryluceneaud">
		<!--- If lucene returns no records --->
		<cfif qryluceneaud.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattreeaud">
			SELECT categorytree
			FROM qryluceneaud
			WHERE categorytree != ''
			GROUP BY categorytree
			ORDER BY categorytree
			</cfquery>
		</cfif>
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry_aud">
		SELECT <cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_id, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_id, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(a.aud_id as varchar(100)), '0')</cfif> id, 
		a.aud_name filename, 
		a.folder_id_r folder_id, 
		a.aud_extension extension, 
		'dummy' as video_image,
		a.aud_name_org filename_org, 
		'aud' as kind, 
		a.aud_extension extension_thumb, 
		a.path_to_asset, 
		a.cloud_url, 
		a.cloud_url_org,
		<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(a.aud_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(a.aud_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(a.aud_size as varchar(100)), '0')</cfif> AS size,
		0 AS width,
		0 AS height,
		aut.aud_description description, 
		aut.aud_keywords keywords,
		a.aud_create_time dateadd,
		a.aud_change_time datechange,
        <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
            concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.astruct.api_key#"]#/',a.path_to_asset,'/',a.aud_name_org) AS local_url_org,
        <cfelseif application.razuna.api.thedatabase EQ "mssql">
            'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.astruct.api_key#"]#/' + a.path_to_asset + '/' + a.aud_name_org AS local_url_org,
         </cfif>
		'0' as local_url_thumb,
		<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
			(
				SELECT GROUP_CONCAT(DISTINCT ac.col_id_r ORDER BY ac.col_id_r SEPARATOR ',') AS col_id
				FROM #application.razuna.api.prefix["#arguments.astruct.api_key#"]#collections_ct_files ac
				WHERE ac.file_id_r = a.aud_id
			) AS colid
		<cfelseif application.razuna.api.thedatabase EQ "mssql">
			STUFF(
				(
					SELECT ', ' + ac.col_id_r
					FROM #application.razuna.api.prefix["#arguments.astruct.api_key#"]#collections_ct_files ac
		         	WHERE ac.file_id_r = a.aud_id
		          	FOR XML PATH ('')
	          	)
	          	, 1, 1, ''
			) AS colid
		<cfelseif application.razuna.api.thedatabase EQ "oracle">
			(
				SELECT wmsys.wm_concat(ac.col_id_r) AS col_id
				FROM #application.razuna.api.prefix["#arguments.astruct.api_key#"]#collections_ct_files ac
				WHERE ac.file_id_r = a.aud_id
			) AS colid
		</cfif>
		,
		'' AS colorspace,
		'' AS xdpi,
		'' AS ydpi,
		'' AS unit,
		a.hashtag AS md5hash,
		fo.folder_name,
		lower(a.aud_name) filename_forsort
		<!--- for UI --->
		<cfif arguments.astruct.ui>
			,
			a.aud_group groupid,
			a.folder_id_r,
			a.aud_extension ext,
			a.is_available,
			a.aud_create_time date_create,
			a.aud_change_time date_change,
			a.link_kind, 
			a.link_path_url,
			'0' as vwidth, 
			'0' as vheight,
			a.hashtag,
			'' as labels,
			'#session.customaccess#' as permfolder,
			<cfif application.razuna.api.thedatabase EQ "mssql">a.aud_id + '-aud'<cfelse>concat(a.aud_id,'-aud')</cfif> as listid
		</cfif>
		FROM #application.razuna.api.prefix["#arguments.astruct.api_key#"]#audios a 
		LEFT JOIN #application.razuna.api.prefix["#arguments.astruct.api_key#"]#audios_text aut ON a.aud_id = aut.aud_id_r AND aut.lang_id_r = 1
		LEFT JOIN #application.razuna.api.prefix["#arguments.astruct.api_key#"]#folders fo ON fo.folder_id = a.folder_id_r AND fo.host_id = a.host_id
		WHERE a.aud_id IN (<cfif qryluceneaud.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreeaud.categorytree)#" list="Yes"></cfif>)
		AND (a.aud_group IS NULL OR a.aud_group = '')
		AND a.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.astruct.api_key#"]#">
		<!--- Only if we have dates --->
		<cfif arguments.astruct.datecreate NEQ "">
			<cfif application.razuna.api.thedatabase EQ "mssql">
				AND (DATEPART(yy, a.aud_create_time) = adate.the_create_year
				AND DATEPART(mm, a.aud_create_time) = adate.the_create_month
				AND DATEPART(dd, a.aud_create_time) = adate.the_create_day)
			<cfelse>
				AND a.aud_create_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.astruct.datecreate#%">
			</cfif>
		</cfif>
		<cfif arguments.astruct.datechange NEQ "">
			<cfif application.razuna.api.thedatabase EQ "mssql">
				AND (DATEPART(yy, a.aud_change_time) = adate.the_change_year
				AND DATEPART(mm, a.aud_change_time) = adate.the_change_month
				AND DATEPART(dd, a.aud_change_time) = adate.the_change_day)
			<cfelse>
				AND a.aud_change_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.astruct.datechange#%">
			</cfif>
		</cfif>
		<cfif arguments.astruct.datecreateparam NEQ "">
			AND a.aud_create_time #arguments.astruct.datecreateparam# <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.astruct.datecreatestart#">
			<cfif arguments.astruct.datecreateparam EQ "between">
				AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.astruct.datecreatestop#">
			</cfif>
		</cfif>
		<cfif arguments.astruct.datechangeparam NEQ "">
			AND a.aud_change_time #arguments.astruct.datechangeparam# <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.astruct.datechangestart#">
			<cfif arguments.astruct.datechangeparam EQ "between">
				AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.astruct.datechangestop#">
			</cfif>
		</cfif>
		<!--- If we have a folderid --->
		<cfif arguments.astruct.folderid NEQ "" AND arguments.astruct.folderid NEQ 0>
			AND a.folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.astruct.folderid#">
		</cfif>
		GROUP BY a.aud_id, a.aud_name, a.folder_id_r, a.aud_extension, a.aud_name_org, a.aud_extension, a.path_to_asset, 
		a.cloud_url, a.cloud_url_org, a.aud_size, aut.aud_description, aut.aud_keywords, a.aud_create_time, a.aud_change_time,
		colorspace, xdpi, ydpi, unit, md5hash, fo.folder_name, filename_forsort
		<cfif arguments.astruct.ui>, folder_name, folder_id_r, ext, is_available, date_create, date_change, link_kind, link_path_url, vwidth, vheight, hashtag, labels, permfolder, listid</cfif>
		ORDER BY filename 
		</cfquery>
		<!--- Add the amount of assets to the query --->
		<cfset var amount = ArrayNew(1)>
		<cfset amount[1] = qry_aud.recordcount>
		<cfset QueryAddcolumn(qry_aud, "cnt", "integer", amount)>
		<!--- Return --->
		<cfreturn qry_aud />
	</cffunction>

	<!--- Search files --->
	<cffunction name="search_files" access="private" output="false" returntype="query">
		<cfargument name="fstruct" required="true">
		<!--- Call date function --->
		<cfset var fdate = set_date(datecreate=arguments.fstruct.datecreate, datechange=arguments.fstruct.datechange)>
		<!--- Search in Lucene --->
		<cfinvoke component="global.cfc.lucene" method="search" criteria="#arguments.fstruct.searchfor#" category="doc" hostid="#application.razuna.api.hostid["#arguments.fstruct.api_key#"]#" returnvariable="qrylucenedoc">
		<!--- If lucene returns no records --->
		<cfif qrylucenedoc.recordcount NEQ 0>
			<!--- Sometimes it can happen that the category tree is empty thus we filter them with a QoQ here --->
			<cfquery dbtype="query" name="cattreedoc">
			SELECT categorytree
			FROM qrylucenedoc
			WHERE categorytree != ''
			GROUP BY categorytree
			ORDER BY categorytree
			</cfquery>
		</cfif>
		<!--- Query --->
		<cfquery datasource="#application.razuna.api.dsn#" name="qry_doc">
		SELECT 
			<cfif application.razuna.api.thedatabase EQ "oracle">
				to_char(NVL(f.file_id, 0))
			<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
				cast(ifnull(f.file_id, 0) AS char)
			<cfelseif application.razuna.api.thedatabase EQ "mssql">
				isnull(cast(f.file_id as varchar(100)), '0')
			</cfif> AS id, 
		f.file_name filename, 
		f.folder_id_r folder_id, 
		f.file_extension extension, 
		'dummy' as video_image,
		f.file_name_org filename_org, 
		'doc' as kind, 
		f.file_extension extension_thumb, 
		f.path_to_asset, 
		f.cloud_url, 
		f.cloud_url_org,
		<cfif application.razuna.api.thedatabase EQ "oracle">to_char(NVL(f.file_size, 0))<cfelseif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">cast(ifnull(f.file_size, 0) AS char)<cfelseif application.razuna.api.thedatabase EQ "mssql">isnull(cast(f.file_size as varchar(100)), '0')</cfif> AS size, 
		0 AS width,
		0 AS height,
		ft.file_desc description, 
		ft.file_keywords keywords,
		f.file_create_time dateadd,
		f.file_change_time datechange,
        <cfif application.razuna.api.thedatabase EQ "oracle" OR application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
            concat('http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.fstruct.api_key#"]#/',f.path_to_asset,'/',f.file_name_org) AS local_url_org,
        <cfelseif application.razuna.api.thedatabase EQ "mssql">
            'http://#cgi.HTTP_HOST#/#application.razuna.api.dynpath#/assets/#application.razuna.api.hostid["#arguments.fstruct.api_key#"]#/' + f.path_to_asset + '/' + f.file_name_org AS local_url_org,
        </cfif>
		'0' as local_url_thumb,
		<cfif application.razuna.api.thedatabase EQ "mysql" OR application.razuna.api.thedatabase EQ "h2">
			(
				SELECT GROUP_CONCAT(DISTINCT fc.col_id_r ORDER BY fc.col_id_r SEPARATOR ',') AS col_id
				FROM #application.razuna.api.prefix["#arguments.fstruct.api_key#"]#collections_ct_files fc
				WHERE fc.file_id_r = f.file_id
			) AS colid
		<cfelseif application.razuna.api.thedatabase EQ "mssql">
			STUFF(
				(
					SELECT ', ' + fc.col_id_r
					FROM #application.razuna.api.prefix["#arguments.fstruct.api_key#"]#collections_ct_files fc
		         	WHERE fc.file_id_r = f.file_id
		          	FOR XML PATH ('')
	          	)
	          	, 1, 1, ''
			) AS colid
		<cfelseif application.razuna.api.thedatabase EQ "oracle">
			(
				SELECT wmsys.wm_concat(fc.col_id_r) AS col_id
				FROM #application.razuna.api.prefix["#arguments.fstruct.api_key#"]#collections_ct_files fc
				WHERE fc.file_id_r = f.file_id
			) AS colid
		</cfif>
		,
		'' AS colorspace,
		'' AS xdpi,
		'' AS ydpi,
		'' AS unit,
		f.hashtag AS md5hash,
		fo.folder_name,
		lower(f.file_name) filename_forsort
		<!--- for UI --->
		<cfif arguments.fstruct.ui>
			,
			'' as groupid,
			f.folder_id_r,
			f.file_extension ext,
			f.is_available,
			f.file_create_time date_create,
			f.file_change_time date_change,
			f.link_kind, 
			f.link_path_url,
			'0' as vwidth, 
			'0' as vheight,
			f.hashtag,
			'' as labels,
			'#session.customaccess#' as permfolder,
			<cfif application.razuna.api.thedatabase EQ "mssql">f.file_id + '-doc'<cfelse>concat(f.file_id,'-doc')</cfif> as listid
		</cfif>
		FROM #application.razuna.api.prefix["#arguments.fstruct.api_key#"]#files f 
		LEFT JOIN #application.razuna.api.prefix["#arguments.fstruct.api_key#"]#files_desc ft ON f.file_id = ft.file_id_r AND ft.lang_id_r = 1
		LEFT JOIN #application.razuna.api.prefix["#arguments.fstruct.api_key#"]#folders fo ON fo.folder_id = f.folder_id_r AND fo.host_id = f.host_id
		WHERE f.file_id IN (<cfif qrylucenedoc.recordcount EQ 0>'0'<cfelse><cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#valuelist(cattreedoc.categorytree)#" list="Yes"></cfif>)
		AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#application.razuna.api.hostid["#arguments.fstruct.api_key#"]#">
		<!--- Only if we have dates --->
		<cfif arguments.fstruct.datecreate NEQ "">
			<cfif application.razuna.api.thedatabase EQ "mssql">
				AND (DATEPART(yy, f.file_create_time) = fdate.the_create_year
				AND DATEPART(mm, f.file_create_time) = fdate.the_create_month
				AND DATEPART(dd, f.file_create_time) = fdate.the_create_day)
			<cfelse>
				AND f.file_create_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fstruct.datecreate#%">
			</cfif>
		</cfif>
		<cfif arguments.fstruct.datechange NEQ "">
			<cfif application.razuna.api.thedatabase EQ "mssql">
				AND (DATEPART(yy, f.file_change_time) = fdate.the_change_year
				AND DATEPART(mm, f.file_change_time) = fdate.the_change_month
				AND DATEPART(dd, f.file_change_time) = fdate.the_change_day)
			<cfelse>
				AND f.file_change_time LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fstruct.datechange#%">
			</cfif>
		</cfif>
		<cfif arguments.fstruct.datecreateparam NEQ "">
			AND f.file_create_time #arguments.fstruct.datecreateparam# <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fstruct.datecreatestart#">
			<cfif arguments.fstruct.datecreateparam EQ "between">
				AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fstruct.datecreatestop#">
			</cfif>
		</cfif>
		<cfif arguments.fstruct.datechangeparam NEQ "">
			AND f.file_change_time #arguments.fstruct.datechangeparam# <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fstruct.datechangestart#">
			<cfif arguments.fstruct.datechangeparam EQ "between">
				AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fstruct.datechangestop#">
			</cfif>
		</cfif>
		<!--- If we have a folderid --->
		<cfif arguments.fstruct.folderid NEQ "" AND arguments.fstruct.folderid NEQ 0>
			AND f.folder_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fstruct.folderid#">
		</cfif>
		GROUP BY f.file_id, f.file_name, f.folder_id_r, f.file_extension, f.file_name_org, f.file_extension, f.path_to_asset, 
		f.cloud_url, f.cloud_url_org, f.file_size, ft.file_desc, ft.file_keywords, f.file_create_time, f.file_change_time, 
		colorspace, xdpi, ydpi, unit, md5hash, fo.folder_name, filename_forsort
		<cfif arguments.fstruct.ui>, folder_name, folder_id_r, ext, is_available, date_create, date_change, link_kind, 
		link_path_url, vwidth, vheight, hashtag, labels, permfolder, listid</cfif>
        ORDER BY filename 
		</cfquery>
		<!--- Add the amount of assets to the query --->
		<cfset var amount = ArrayNew(1)>
		<cfset amount[1] = qry_doc.recordcount>
		<cfset QueryAddcolumn(qry_doc, "cnt", "integer", amount)>
		<!--- If we query for doc only and have a filetype we filter the results --->
		<cfif arguments.fstruct.show NEQ "all" AND arguments.fstruct.show EQ "doc" AND arguments.fstruct.doctype NEQ "">
			<cfquery dbtype="query" name="qry">
			SELECT *
			FROM qry
			<cfswitch expression="#arguments.fstruct.doctype#">
				<cfcase value="doc">
					WHERE qry.extension = <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
				</cfcase>
				<cfcase value="xls">
					WHERE qry.extension = <cfqueryparam value="xls" cfsqltype="cf_sql_varchar">
				</cfcase>
				<cfcase value="pdf">
					WHERE qry.extension = <cfqueryparam value="pdf" cfsqltype="cf_sql_varchar">
				</cfcase>
				<cfcase value="other">
					WHERE qry.extension != <cfqueryparam value="pdf" cfsqltype="cf_sql_varchar">
					AND qry.extension != <cfqueryparam value="xls" cfsqltype="cf_sql_varchar">
					AND qry.extension != <cfqueryparam value="xlsx" cfsqltype="cf_sql_varchar">
					AND qry.extension != <cfqueryparam value="doc" cfsqltype="cf_sql_varchar">
					AND qry.extension != <cfqueryparam value="docx" cfsqltype="cf_sql_varchar">
				</cfcase>
			</cfswitch>
			</cfquery>
		</cfif>
		<!--- Return --->
		<cfreturn qry_doc />
	</cffunction>

	<!--- Date function --->
	<cffunction name="set_date" returntype="Struct">
		<cfargument name="datecreate" required="true">
		<cfargument name="datechange" required="true">
		<!--- Param --->
		<cfset var sd = structNew()>
		<!--- If we are on MS SQL the date has to be formated differently --->
		<cfif application.razuna.api.thedatabase EQ "mssql">
			<!--- Set the counter --->
			<cfset var thecountercreate = 1>
			<cfset var thecounterchange = 1>
			<cfif arguments.datecreate NEQ "">
				<cfloop list="#arguments.datecreate#" delimiters="-" index="i">
					<cfif thecountercreate EQ 1>
						<cfset sd.the_create_year = i>
					<cfelseif thecountercreate EQ 2>
						<cfset sd.the_create_month = i>
					<cfelseif thecountercreate EQ 3>
						<cfset sd.the_create_day = i>
					</cfif>
					<!--- Increase the counter --->
					<cfset var thecountercreate = thecountercreate + 1>
				</cfloop>
			</cfif>
			<cfif arguments.datechange NEQ "">
				<cfloop list="#arguments.datechange#" delimiters="-" index="i">
					<cfif thecounterchange EQ 1>
						<cfset sd.the_change_year = i>
					<cfelseif thecounterchange EQ 2>
						<cfset sd.the_change_month = i>
					<cfelseif thecounterchange EQ 3>
						<cfset sd.the_change_day = i>
					</cfif>
					<!--- Increase the counter --->
					<cfset var thecounterchange = thecounterchange + 1>
				</cfloop>
			</cfif>
		</cfif>
		<!--- Return --->
		<cfreturn sd />
	</cffunction>

</cfcomponent>