<?xml version="1.0"?>
<!-- xsl:text><?xml version="1.0" encoding="UTF-8" ?></xsl:text -->
<!-- 
     @what - xslt processor for SGI IRIX Man pages that have gone through ANSI Processor

     @author - John Hartley - Graphica Software / Dokmai Pty Ltd

     (c) Copyright 2023 - All right reserved
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1" xmlns:html="http://www.w3.org/1999/xhtml">
<xsl:output omit-xml-declaration="no" indent="no" encoding="UTF-8" method="html" version="4.0" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" />
<xsl:template match="html:span[@style='color:white;background-color:black;']">
<!-- xsl:template match="html:span[@style]" -->
<xsl:copy>
<xsl:apply-templates select="@*"/>
<xsl:attribute name="style">text-decoration:underline;font-weight:bold;</xsl:attribute>
<!-- xsl:attribute name="style">FROG</xsl:attribute -->
<xsl:apply-templates select="node()"/>
</xsl:copy>
</xsl:template>
<xsl:template match="@*|node()">
<xsl:copy>
<xsl:apply-templates select="@*|node()"/>
</xsl:copy>
</xsl:template>
</xsl:stylesheet>
