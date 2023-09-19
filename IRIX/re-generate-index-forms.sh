#!/bin/sh
#
# @what - just source this..
#
if [ "${1}" = "d" ]; then 
	cd /usr/local/www/cache
	rm freebsd-13.2/index/index-form.html 
	rm freebsd-13.2/index/index-form-alt.html 
	rm freebsd-2.0.5/index/index-form.html
	rm freebsd-2.0.5/index/index-form-alt.html
	rm unix-7th-edition/index/index-form.html
	rm unix-7th-edition/index/index-form-alt.html
	rm irix-6.5.30/index/index-form.html
	rm irix-6.5.30/index/index-form-alt.html
	cp irix-6.5.30/index/index.html.bak irix-6.5.30/index/index.html
	cp irix-6.5.30/index/index-alt.html.bak irix-6.5.30/index/index-alt.html
fi
#
if [ "${1}" = "c" ]; then
	cd /usr/home/jbh/documents/irix-man
	QUERY_STRING="topic=&section=0&osver=IRIX-6.5.30&sort=bypage&do=index" REQUEST_METHOD="GET" perl page-search.pl
	QUERY_STRING="topic=&section=0&osver=IRIX-6.5.30&sort=bysec&do=index" REQUEST_METHOD="GET" perl page-search.pl
	QUERY_STRING="topic=&section=0&osver=FreeBSD-13.2&sort=bypage&do=index" REQUEST_METHOD="GET" perl page-search.pl
	QUERY_STRING="topic=&section=0&osver=FreeBSD-13.2&sort=bysec&do=index" REQUEST_METHOD="GET" perl page-search.pl
	QUERY_STRING="topic=&section=0&osver=FreeBSD-2.0.5&sort=bypage&do=index" REQUEST_METHOD="GET" perl page-search.pl
	QUERY_STRING="topic=&section=0&osver=FreeBSD-2.0.5&sort=bysec&do=index" REQUEST_METHOD="GET" perl page-search.pl
	QUERY_STRING="topic=&section=0&osver=UNIX-7th-Edition&sort=bypage&do=index" REQUEST_METHOD="GET" perl page-search.pl
	QUERY_STRING="topic=&section=0&osver=UNIX-7th-Edition&sort=bysec&do=index" REQUEST_METHOD="GET" perl page-search.pl
fi
