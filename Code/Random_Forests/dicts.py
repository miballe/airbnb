import numpy as np

def inv_dict(map_dict):
	"""Creates an inverse dictionary map"""
	inv_map = {v:k for k, v in map_dict.items()}
	return inv_map


gender_ord = {"FEMALE":0, "MALE":1, "OTHER":2, "-unknown-":3, -1:-1}

signup_method_ord = {'facebook':0, 'basic':1, 'google':2, 'weibo':3, -1:-1}

language_ord = {'en':0, 'fr':1, 'de':2, 'es':3, 'it':4, 'pt':5, 'zh':6, 'ko':7,
				'ja':8, 'ru':9, 'pl':10, 'el':11, 'sv':12, 'nl':13, 'hu':14,
				'da':15, 'id':16, 'fi':17, 'no':18, 'tr':19, 'th':20, 'cs':21,
				'hr':22, 'ca':23, 'is':24, '-unknown-':25, -1:-1}

affiliate_channel_ord = {'direct':0, 'seo':1, 'other':2, 'sem-non-brand':3,
						 'content':4, 'sem-brand':5, 'remarketing':6, 'api':7, -1:-1}

affiliate_provider_ord = {'direct':0, 'google':1, 'other':2, 'craigslist':3,
						  'facebook':4, 'vast':5, 'bing':6, 'meetup':7,
						  'facebook-open-graph':8, 'email-marketing':9, 'yahoo':10,
						  'padmapper':11, 'gsp':12, 'wayn':13, 'naver':14,
						  'baidu':15, 'yandex':16, 'daum':17, -1:-1}

first_affiliate_tracked_ord = {'untracked':0, 'omg':1, 'linked':2, 
							   'tracked-other':3, 'product':4, 'marketing':5,
							   'local ops':6, 'nan':-1, -1:-1}

signup_app_ord = {'Web':0, 'Moweb':1, 'iOS':2, 'Android':3, -1:-1}

first_device_type_ord = {'Mac Desktop':0, 'Windows Desktop':1, 'iPhone':2, 
						 'Other/Unknown':3, 'Desktop (Other)':4, 'Android Tablet':5,
						 'iPad':6, 'Android Phone':7, 'SmartPhone (Other)':8, -1:-1}

first_browser_ord = {'Chrome':0, 'IE':1, 'Firefox':2, 'Safari':3, '-unknown-':4,
					 'Mobile Safari':5, 'Chrome Mobile':6, 'RockMelt':7,
					 'Chromium':8, 'Android Browser':9, 'AOL Explorer':10,
					 'Palm Pre web browser':11, 'Mobile Firefox':12, 'Opera':13,
					 'TenFourFox':14, 'IE Mobile':15, 'Apple Mail':16, 'Silk':17,
					 'Camino':18, 'Arora':19, 'BlackBerry Browser':20, 'SeaMonkey':21,
					 'Iron':22, 'Sogou Explorer':23, 'IceWeasel':24, 'Opera Mini':25,
					 'SiteKiosk':26, 'Maxthon':27, 'Kindle Browser':28,
					 'CoolNovo':29, 'Conkeror':30, 'wOSBrowser':31, 'Google Earth':32,
					 'Crazy Browser':33, 'Mozilla':34, 'OmniWeb':35, 
					 'PS Vita browser':36, 'NetNewsWire':37, 'CometBird':38,
					 'Comodo Dragon':39, 'Flock':40, 'Pale Moon':41,
					 'Avant Browser':42, 'Opera Mobile':43, 'Yandex.Browser':44,
					 'TheWorld Browser':45, 'SlimBrowser':46, 'Epic':47,
					 'Stainless':48, 'Googlebot':49, 'Outlook 2007':50, 'IceDragon':51,
					 'IBrowse':52, 'Nintendo Browser':53, 'UC Browser':54, -1:-1}

country_ord = {"NDF":0, "US":1, "other":2, "FR":3, "CA":4, "GB":5, "ES":6,
			   "IT":7, "PT":8, "NL":9, "DE":10, "AU":11}

country = inv_dict(country_ord)

# which cols to read in
default_cols = ["id", "date_account_created", "timestamp_first_active",
					  "date_first_booking", "gender", "age", "signup_method",
					  "signup_flow", "language", "affiliate_channel", 
					  "affiliate_provider", "first_affiliate_tracked", "signup_app",
					  "first_device_type", "first_browser"]

# remove the id field for the random forest
columns = ["age", "signup_flow", "gender", "signup_method", "language",
		   "affiliate_channel", "affiliate_provider", "first_affiliate_tracked",
		   "signup_app", "first_device_type", "first_browser"]

users_hot_encode_cols = ["dac_year","dac_month","dac_day","dac_week","dac_yearweek","dac_yearmonthday","dac_yearmonthweek","tfa_week","tfa_yearweek","tfa_yearmonthday","tfa_yearmonthweek","lag","NAs_profile","age_NAs","gender_NAs","genderFEMALE","genderMALE","genderNA","genderOTHER","signup_methodbasic","signup_methodfacebook","signup_methodgoogle","signup_methodweibo","signup_flow","language-unknown-","languageca","languagecs","languageda","languagede","languageel","languageen","languagees","languagefi","languagefr","languagehr","languagehu","languageid","languageis","languageit","languageja","languageko","languagenl","languageno","languagepl","languagept","languageru","languagesv","languageth","languagetr","languagezh","affiliate_channelapi","affiliate_channelcontent","affiliate_channeldirect","affiliate_channelother","affiliate_channelremarketing","affiliate_channelsem-brand","affiliate_channelsem-non-brand","affiliate_channelseo","affiliate_providerbaidu","affiliate_providerbing","affiliate_providercraigslist","affiliate_providerdaum","affiliate_providerdirect","affiliate_provideremail-marketing","affiliate_providerfacebook","affiliate_providerfacebook-open-graph","affiliate_providergoogle","affiliate_providergsp","affiliate_providermeetup","affiliate_providernaver","affiliate_providerother","affiliate_providerpadmapper","affiliate_providervast","affiliate_providerwayn","affiliate_provideryahoo","affiliate_provideryandex","first_affiliate_trackedlinked","first_affiliate_trackedlocal ops","first_affiliate_trackedmarketing","first_affiliate_trackedNA","first_affiliate_trackedomg","first_affiliate_trackedproduct","first_affiliate_trackedtracked-other","first_affiliate_trackeduntracked","signup_appAndroid","signup_appiOS","signup_appMoweb","signup_appWeb","first_device_typeAndroid Phone","first_device_typeAndroid Tablet","first_device_typeDesktop (Other)","first_device_typeiPad","first_device_typeiPhone","first_device_typeMac Desktop","first_device_typeOther/Unknown","first_device_typeSmartPhone (Other)","first_device_typeWindows Desktop","first_browser-unknown-","first_browserAndroid Browser","first_browserAOL Explorer","first_browserApple Mail","first_browserArora","first_browserAvant Browser","first_browserBlackBerry Browser","first_browserCamino","first_browserChrome","first_browserChrome Mobile","first_browserChromium","first_browserCometBird","first_browserComodo Dragon","first_browserConkeror","first_browserCoolNovo","first_browserCrazy Browser","first_browserEpic","first_browserFirefox","first_browserFlock","first_browserGoogle Earth","first_browserGooglebot","first_browserIBrowse","first_browserIceDragon","first_browserIceWeasel","first_browserIE","first_browserIE Mobile","first_browserIron","first_browserKindle Browser","first_browserMaxthon","first_browserMobile Firefox","first_browserMobile Safari","first_browserMozilla","first_browserNetNewsWire","first_browserNintendo Browser","first_browserOmniWeb","first_browserOpera","first_browserOpera Mini","first_browserOpera Mobile","first_browserOutlook 2007","first_browserPale Moon","first_browserPalm Pre web browser","first_browserPS Vita browser","first_browserRockMelt","first_browserSafari","first_browserSeaMonkey","first_browserSilk","first_browserSiteKiosk","first_browserSlimBrowser","first_browserSogou Explorer","first_browserStainless","first_browserTenFourFox","first_browserTheWorld Browser","first_browserUC Browser","first_browserwOSBrowser","first_browserYandex.Browser","dac_yearmonth201001","dac_yearmonth201002","dac_yearmonth201003","dac_yearmonth201004","dac_yearmonth201005","dac_yearmonth201006","dac_yearmonth201007","dac_yearmonth201008","dac_yearmonth201009","dac_yearmonth201010","dac_yearmonth201011","dac_yearmonth201012","dac_yearmonth201101","dac_yearmonth201102","dac_yearmonth201103","dac_yearmonth201104","dac_yearmonth201105","dac_yearmonth201106","dac_yearmonth201107","dac_yearmonth201108","dac_yearmonth201109","dac_yearmonth201110","dac_yearmonth201111","dac_yearmonth201112","dac_yearmonth201201","dac_yearmonth201202","dac_yearmonth201203","dac_yearmonth201204","dac_yearmonth201205","dac_yearmonth201206","dac_yearmonth201207","dac_yearmonth201208","dac_yearmonth201209","dac_yearmonth201210","dac_yearmonth201211","dac_yearmonth201212","dac_yearmonth201301","dac_yearmonth201302","dac_yearmonth201303","dac_yearmonth201304","dac_yearmonth201305","dac_yearmonth201306","dac_yearmonth201307","dac_yearmonth201308","dac_yearmonth201309","dac_yearmonth201310","dac_yearmonth201311","dac_yearmonth201312","dac_yearmonth201401","dac_yearmonth201402","dac_yearmonth201403","dac_yearmonth201404","dac_yearmonth201405","dac_yearmonth201406","dac_yearmonth201407","dac_yearmonth201408","dac_yearmonth201409","tfa_year2009","tfa_year2010","tfa_year2011","tfa_year2012","tfa_year2013","tfa_year2014","tfa_month01","tfa_month02","tfa_month03","tfa_month04","tfa_month05","tfa_month06","tfa_month07","tfa_month08","tfa_month09","tfa_month10","tfa_month11","tfa_month12","tfa_day01","tfa_day02","tfa_day03","tfa_day04","tfa_day05","tfa_day06","tfa_day07","tfa_day08","tfa_day09","tfa_day10","tfa_day11","tfa_day12","tfa_day13","tfa_day14","tfa_day15","tfa_day16","tfa_day17","tfa_day18","tfa_day19","tfa_day20","tfa_day21","tfa_day22","tfa_day23","tfa_day24","tfa_day25","tfa_day26","tfa_day27","tfa_day28","tfa_day29","tfa_day30","tfa_day31","tfa_yearmonth200903","tfa_yearmonth200905","tfa_yearmonth200906","tfa_yearmonth200910","tfa_yearmonth200912","tfa_yearmonth201001","tfa_yearmonth201002","tfa_yearmonth201003","tfa_yearmonth201004","tfa_yearmonth201005","tfa_yearmonth201006","tfa_yearmonth201007","tfa_yearmonth201008","tfa_yearmonth201009","tfa_yearmonth201010","tfa_yearmonth201011","tfa_yearmonth201012","tfa_yearmonth201101","tfa_yearmonth201102","tfa_yearmonth201103","tfa_yearmonth201104","tfa_yearmonth201105","tfa_yearmonth201106","tfa_yearmonth201107","tfa_yearmonth201108","tfa_yearmonth201109","tfa_yearmonth201110","tfa_yearmonth201111","tfa_yearmonth201112","tfa_yearmonth201201","tfa_yearmonth201202","tfa_yearmonth201203","tfa_yearmonth201204","tfa_yearmonth201205","tfa_yearmonth201206","tfa_yearmonth201207","tfa_yearmonth201208","tfa_yearmonth201209","tfa_yearmonth201210","tfa_yearmonth201211","tfa_yearmonth201212","tfa_yearmonth201301","tfa_yearmonth201302","tfa_yearmonth201303","tfa_yearmonth201304","tfa_yearmonth201305","tfa_yearmonth201306","tfa_yearmonth201307","tfa_yearmonth201308","tfa_yearmonth201309","tfa_yearmonth201310","tfa_yearmonth201311","tfa_yearmonth201312","tfa_yearmonth201401","tfa_yearmonth201402","tfa_yearmonth201403","tfa_yearmonth201404","tfa_yearmonth201405","tfa_yearmonth201406","tfa_yearmonth201407","tfa_yearmonth201408","tfa_yearmonth201409","age-1","age100","age14","age15","age16","age17","age18","age19","age20","age21","age22","age23","age24","age25","age26","age27","age28","age29","age30","age31","age32","age33","age34","age35","age36","age37","age38","age39","age40","age41","age42","age43","age44","age45","age46","age47","age48","age49","age50","age51","age52","age53","age54","age55","age56","age57","age58","age59","age60","age61","age62","age63","age64","age65","age66","age67","age68","age69","age70","age71","age72","age73","age74","age75","age76","age77","age78","age79","age80","age81","age82","age83","age84","age85","age86","age87","age88","age89","age90","age91","age92","age93","age94","age95","age96","age97","age98","age99","ageNA","age_bucket0-4","age_bucket100+","age_bucket15-19","age_bucket20-24","age_bucket25-29","age_bucket30-34","age_bucket35-39","age_bucket40-44","age_bucket45-49","age_bucket5-9","age_bucket50-54","age_bucket55-59","age_bucket60-64","age_bucket65-69","age_bucket70-74","age_bucket75-79","age_bucket80-84","age_bucket85-89","age_bucket90-94","age_bucket95-99","age_bucketNA"]

