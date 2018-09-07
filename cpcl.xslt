<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:z="http://www.fensystems.co.uk/xmlns/cpcl"
		version="1.0">

  <!-- Output in plain text -->
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <!-- CRLF line ending -->
  <xsl:template name="crlf">
    <xsl:text>&#xd;&#xa;</xsl:text>
  </xsl:template>

  <!-- Convert element name to (uppercase) CPCL command name -->
  <xsl:template name="command">
    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <xsl:value-of select="translate(local-name(),$lowercase,$uppercase)"/>
  </xsl:template>

  <!-- Root element -->
  <xsl:template match="/z:cpcl">
    <xsl:text>! </xsl:text>
    <xsl:choose>
      <xsl:when test="@offset"><xsl:value-of select="@offset"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@xdpi"><xsl:value-of select="@xdpi"/></xsl:when>
      <xsl:when test="@dpi"><xsl:value-of select="@dpi"/></xsl:when>
      <xsl:otherwise><xsl:text>200</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@ydpi"><xsl:value-of select="@ydpi"/></xsl:when>
      <xsl:when test="@dpi"><xsl:value-of select="@dpi"/></xsl:when>
      <xsl:otherwise><xsl:text>200</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@qty"><xsl:value-of select="@qty"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
    <xsl:apply-templates/>
    <xsl:text>PRINT</xsl:text>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Fail on unknown elements -->
  <xsl:template match="*">
    <xsl:message terminate="yes">Unrecognised element:
    <xsl:value-of select="local-name()"/>
    </xsl:message>
  </xsl:template>

  <!-- Raw quoted commands -->
  <xsl:template match="z:cpcl/z:raw">
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Comments -->
  <xsl:template match="z:cpcl/comment()">
    <xsl:text>;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Zero parameter commands -->
  <xsl:template match="z:cpcl/z:form |
		       z:cpcl/z:in-inches |
		       z:cpcl/z:in-centimeters |
		       z:cpcl/z:in-millimeters |
		       z:cpcl/z:in-dots">
    <xsl:call-template name="command"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Single parameter commands -->
  <xsl:template match="z:cpcl/z:encoding |
		       z:cpcl/z:count">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Text commands -->
  <xsl:template match="z:cpcl/z:text |
		       z:cpcl/z:t |
		       z:cpcl/z:vtext |
		       z:cpcl/z:vt |
		       z:cpcl/z:text90 |
		       z:cpcl/z:t90 |
		       z:cpcl/z:text180 |
		       z:cpcl/z:t180 |
		       z:cpcl/z:text270 |
		       z:cpcl/z:t270">
    <xsl:call-template name="command"/>
    <xsl:call-template name="text-attributes"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>
  <xsl:template name="text-attributes">
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@font"><xsl:value-of select="@font"/></xsl:when>
      <xsl:when test="@fg"><xsl:text>FG</xsl:text></xsl:when>
      <xsl:otherwise><xsl:text>4</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@size"><xsl:value-of select="@size"/></xsl:when>
      <xsl:when test="@fg"><xsl:value-of select="@fg"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Font group command -->
  <xsl:template match="z:cpcl/z:fg |
		       z:cpcl/z:concat/z:fg |
		       z:cpcl/z:vconcat/z:fg">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@fg"><xsl:value-of select="@fg"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
    <xsl:call-template name="crlf"/>
  </xsl:template>
  <xsl:template match="z:fg/z:f">
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@font"><xsl:value-of select="@font"/></xsl:when>
      <xsl:otherwise><xsl:text>4</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@size"><xsl:value-of select="@size"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Text concatenation commands -->
  <xsl:template match="z:cpcl/z:concat |
		       z:cpcl/z:vconcat">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@x"><xsl:value-of select="@x"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@y"><xsl:value-of select="@y"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
    <xsl:apply-templates/>
    <xsl:text>ENDCONCAT</xsl:text>
    <xsl:call-template name="crlf"/>
  </xsl:template>
  <xsl:template match="z:concat/z:text |
		       z:vconcat/z:text">
    <xsl:choose>
      <xsl:when test="@font"><xsl:value-of select="@font"/></xsl:when>
      <xsl:when test="@fg"><xsl:text>FG</xsl:text></xsl:when>
      <xsl:otherwise><xsl:text>4</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@size"><xsl:value-of select="@size"/></xsl:when>
      <xsl:when test="@fg"><xsl:value-of select="@fg"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@offset"><xsl:value-of select="@offset"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Multiline commands -->
  <xsl:template match="z:cpcl/z:multiline |
		       z:cpcl/z:ml">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
      <xsl:otherwise><xsl:text>0</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
    <xsl:text>TEXT</xsl:text>
    <xsl:call-template name="text-attributes"/>
    <xsl:call-template name="crlf"/>
    <xsl:apply-templates/>
    <xsl:text>END</xsl:text><xsl:call-template name="command"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>
  <xsl:template match="z:multiline/z:line |
		       z:ml/z:line">
    <xsl:value-of select="text()"/>
    <xsl:call-template name="crlf"/>
  </xsl:template>

  <!-- Set magnification command -->
  <xsl:template match="z:cpcl/z:setmag">
    <xsl:call-template name="command"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@width"><xsl:value-of select="@width"/></xsl:when>
      <xsl:when test="@scale"><xsl:value-of select="@scale"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@height"><xsl:value-of select="@height"/></xsl:when>
      <xsl:when test="@scale"><xsl:value-of select="@scale"/></xsl:when>
      <xsl:otherwise><xsl:text>1</xsl:text></xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="crlf"/>
  </xsl:template>

</xsl:stylesheet>
