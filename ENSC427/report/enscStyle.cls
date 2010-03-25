% Report style - based on
% Systems Design Engineering Report Style
%
% Created by Matthew Zulak <mzulak@engmail> with assistance from
% Prof. G. Heppler <heppler@uwaterloo.ca>.
%
% Updated by Darcy Parks <dparks@engmail>
% 
% Updated by Dan Hendry - Changed for ENSC at Simon Fraser University
%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{enscStyle}

%##################################
%   Internal Variables
%##################################

\newif\iftwoside

% Ensure the ifHtml variable is set
%\usepackage{ifpdf}
\ifx\ifHtml\undefined
	\newif\ifHtml
\fi
%\ifpdf
%	\ifx\ifHtml\undefined
%		\newif\Html
%	\fi
%\else
%	\ifx\ifHtml\undefined
%		\newif\Html
%	\fi
%\fi

%##################################
%   Options for class
%##################################

\DeclareOption{twoside}{\PassOptionsToClass{twoside}{report}\twosidetrue}
\ProcessOptions

%##################################
%   Main Packages
%##################################

\LoadClass[12pt]{report}

\usepackage{textcase}
\usepackage{setspace}
\usepackage{scalefnt}
\usepackage{url}
\usepackage{graphicx}

\usepackage{ifpdf}
%Note ifpdf package loaded above

% Conditional package loading
% tex4ht fucks with pdflatex
\ifHtml
	\usepackage{tex4ht}
	%\usepackage[tex4ht]{hyperref}
\else
	\ifpdf
		\usepackage{hyperref}
	\fi
\fi

\relax %TODO: what is this? - Needed?

%##################################
%   Variables for class
%##################################

\newcommand{\@coursecode} {}
\newcommand{\coursecode}[1]{
	\renewcommand{\@coursecode}{#1}
}
\newcommand{\@prof} {}
\newcommand{\prof}[1]{
	\renewcommand{\@prof}{#1}
}

%##################################
%   Commands
%##################################

\let\Oldchapter\chapter
\renewcommand{\chapter}
{
	\ifHtml
		\HCode{<hr/>}
	\else
		\iftwoside
			\cleardoublepage
		\fi		
	\fi
	\Oldchapter
}

\newcommand{\degree}{\ensuremath{^\circ}}

%##################################
%   Page layout and formatting
%##################################

\renewcommand{\chaptername}{}
\renewcommand{\baselinestretch}{1.5}
\renewcommand{\textfraction}{0.01}
\renewcommand{\topfraction}{0.99}
\renewcommand{\bottomfraction}{0.99}
\setlength{\oddsidemargin}{0.5in}
\setlength{\evensidemargin}{0.0in}
\setlength{\textwidth}{6in}
\setlength{\topmargin}{0in}
\setlength{\headheight}{0in}
\setlength{\headsep}{0in}
\setlength{\textheight}{9in}

\newcounter{figs}
\newcounter{eqns}
\newcounter{tabs}
\setcounter{secnumdepth}{2}

\renewcommand\bibname{References}
\bibliographystyle{IEEEtran}

%##################################
%   Title Page
%##################################

\renewcommand{\maketitle}{
\ifpdf
	\hypersetup{pdftitle={\@title}, pdfauthor={\@author}}
\fi
\begin{titlepage}
	\vspace*{2em}
	\begin{center}
		{\Huge\@title}
	\end{center}
	\null\vfill

	\begin{center}
		{A Report Submitted in Partial Fulfillment\\
		of the Requirements for ENSC \@coursecode}
	\end{center}
	\vskip 2em

	\ifHtml
		\HCode{<br/>}
		\HCode{<br/>}
	\fi

	\begin{center}
		\@author\par
	\end{center}
	\vskip 2em
	
	\ifHtml
		\HCode{<br/>}
	\fi
	
	\begin{center}
		{Simon Fraser University \\
		School of Engineering Science}
	\end{center}
	\vskip 2em

	\ifHtml
		\HCode{<br/>}
	\fi

	\begin{center}
		{\@date\\
		Course Instructor: \@prof}
	\end{center}
\end{titlepage}
\ifHtml
	\HCode{<hr/>}
\fi
}
%}