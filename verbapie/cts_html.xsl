<?xml version="1.0" encoding="UTF-8"?>
<!--

Part of verbapy https://github.com/galenus-verbatim/verbapy
Copyright (c) 2021 Nathalie Rousseau
MIT License https://opensource.org/licenses/mit-license.php


Split a single TEI file in a multi-pages site

-->
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei"
>
  <xsl:output indent="yes" encoding="UTF-8" method="html" />
  <!-- A handle on each line breaks by its page to count lines -->
  <xsl:key name="line-by-page" match="tei:item|tei:l|tei:lb|tei:p" use="generate-id(preceding::tei:pb[1])"/>

  <xsl:template match="tei:*">
    <xsl:message terminate="yes">
      <xsl:text>[cts_html.xsl] </xsl:text>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>&gt;</xsl:text>
      <xsl:text> TEI tag not yet handled</xsl:text>
    </xsl:message>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:add">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:del"/>
  
  <xsl:template match="tei:div">
    <xsl:text>&#10;</xsl:text>
    <section>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </section>
  </xsl:template>
  
  <xsl:template match="tei:figDesc">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:figure">
    <xsl:text>&#10;</xsl:text>
    <figure>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </figure>
  </xsl:template>  
  
  <!-- Graphic founds seem links 
  <graphic url="https://babel.hathitrust.org/cgi/pt?id=hvd.hxpp8p;view=2up;seq=514"/>
  -->
  <xsl:template match="tei:graphic">
    <xsl:text>&#10;</xsl:text>
    <a href="{@url}">
      <xsl:text>[p. </xsl:text>
      <xsl:value-of select="(preceding::tei:pb)[1]/@n"/>
      <xsl:text>]</xsl:text>
    </a>
  </xsl:template>
  
  
  <xsl:template match="tei:gap"/>
  
  <xsl:template match="tei:head">
    <xsl:text>&#10;</xsl:text>
    <h1>
      <xsl:apply-templates/>
    </h1>
  </xsl:template>

  <xsl:template match="tei:lb">
    <xsl:text>&#10;</xsl:text>
    <span class="lb">
      <xsl:call-template name="data-line"/>
    </span>
  </xsl:template>
  
  <xsl:template name="data-line">
    <!-- Count lines from the last page break. If not…? not predicted -->
    <xsl:variable name="pb" select="generate-id(preceding::tei:pb[1])"/>
    
    <xsl:variable name="id" select="generate-id()"/>
    <!-- Seems not efficient but is well compiled and do not fall in hyperspace like some weird xpath -->
    <xsl:variable name="n">
      <xsl:for-each select="key('line-by-page', $pb)">
        <xsl:if test="generate-id(.) = $id">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="number($n) &gt; 0">
      <xsl:attribute name="data-line">
        <xsl:value-of select="$n + 1"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:l">
    <xsl:text>&#10;</xsl:text>
    <div class="l">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="tei:label">
    <xsl:text>&#10;</xsl:text>
    <label>
      <xsl:apply-templates/>
    </label>
  </xsl:template>
  
  <xsl:template match="tei:label/tei:num">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:item">
    <xsl:text>&#10;</xsl:text>
    <li>
      <xsl:apply-templates/>
    </li>
  </xsl:template>
  
  <xsl:template match="tei:list">
    <xsl:text>&#10;</xsl:text>
    <ul>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </ul>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='table']">
    <xsl:text>&#10;</xsl:text>
    <table>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </table>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='table']/tei:item">
    <xsl:text>&#10;</xsl:text>
    <tbody>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </tbody>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='table']/tei:item[1]">
    <xsl:text>&#10;</xsl:text>
    <thead>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </thead>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='row']">
    <xsl:text>&#10;</xsl:text>
    <tr>
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </tr>
  </xsl:template>
  
  <xsl:template match="tei:list[@rend='row']/tei:item">
    <xsl:choose>
      <xsl:when test="tei:label and count(*) = 1 and not(text()[normalize-space(.) != ''])">
        <xsl:text>&#10;</xsl:text>
        <th>
          <xsl:apply-templates select="tei:label/node()"/>
        </th>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#10;</xsl:text>
        <td>
          <xsl:apply-templates/>
        </td>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:lg">
    <xsl:text>&#10;</xsl:text>
    <div class="lg">
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </div>
  </xsl:template>
  
  <xsl:template match="tei:milestone">
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="normalize-space(concat('milestone ', @unit))"/>
      </xsl:attribute>
      <xsl:if test="@n">
        <xsl:attribute name="data-n">
          <xsl:value-of select="@n"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@unit">
        <xsl:attribute name="data-unit">
          <xsl:value-of select="@unit"/>
        </xsl:attribute>
      </xsl:if>
    </span>
  </xsl:template>
  

  <!-- Check if notes are interesting and find a good way to display and index -->
  <xsl:template match="tei:note">
    <xsl:text>&#10;</xsl:text>
    <xsl:comment>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text>&gt; </xsl:text>
      <xsl:value-of select="."/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match="tei:p">
    <xsl:text>&#10;</xsl:text>
    <p>
      <xsl:call-template name="data-line"/>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  
  <xsl:template match="tei:pb">
    <xsl:param name="class"/>
    <xsl:text>&#10;</xsl:text>
    <span class="pb">
      <xsl:attribute name="class">
        <xsl:value-of select="normalize-space(concat('pb ', $class))"/>
      </xsl:attribute>
      <xsl:if test="@n">
        <xsl:attribute name="data-page">
          <xsl:value-of select="@n"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$class = ''">
        <xsl:attribute name="data-line">1</xsl:attribute>
      </xsl:if>
    </span>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:q">
    <q class="q">
      <xsl:apply-templates/>
    </q>
  </xsl:template>
  
  <!-- Will produce bad html for p/quote -->
  <xsl:template match="tei:quote">
    <xsl:text>&#10;</xsl:text>
    <blockquote class="quote">
      <xsl:apply-templates/>
      <xsl:text>&#10;</xsl:text>
    </blockquote>
  </xsl:template>
  
</xsl:transform>