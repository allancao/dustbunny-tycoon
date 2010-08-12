%##################################
%   
%   Lab report style
%   
%##################################

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{enscStyle}

%\LoadClass{article}
\LoadClass{report}

%##################################
%   Options for class
%##################################

\DeclareOption{11pt}{\PassOptionsToClass{11pt}{report}}
\DeclareOption{12pt}{\PassOptionsToClass{12pt}{report}}
%\DeclareOption{11pt}{\PassOptionsToClass{11pt}{article}}
%\DeclareOption{12pt}{\PassOptionsToClass{12pt}{article}}
%\DeclareOption{twocolumn}{\PassOptionsToClass{twocolumn}{article}}
\ProcessOptions

%##################################
%   Main Packages
%##################################

\usepackage[margin=1in]{geometry}
\usepackage{booktabs}
%\usepackage{multirow}
\usepackage{tabularx}
\usepackage{amsmath,amssymb}
\usepackage{textcase}
\usepackage{setspace}
%\usepackage{scalefnt}
\usepackage{url}
\usepackage{graphicx}
\usepackage{hyperref}

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

\newcommand{\q}[1]{\lq{}#1\rq{}}

%##################################
%   Page layout and formatting
%##################################

%\setlength{\parindent}{0pt} 
%\setlength{\parskip}{1.5ex}
\renewcommand{\baselinestretch}{2}

\setcounter{secnumdepth}{2}
\newcounter{figs}
\newcounter{eqns}
\newcounter{tabs}

%\renewcommand\bibname{References}
\bibliographystyle{IEEEtran}


%##################################
%   Title Page
%##################################

\renewcommand{\maketitle}{
\hypersetup{pdftitle={\@title}, pdfauthor={\@author}}
\begin{titlepage}
	\renewcommand{\baselinestretch}{1.2}
	\vspace*{10em}
	\begin{center}
		{\Huge\@title}
	\end{center}
	
	\vskip 4em
	
	\begin{center}
		{\LARGE\@coursecode\par}
	\end{center}
	
	\null\vfill

	\vskip 2em

	\begin{center}
		{\Large\@author\par}
	\end{center}
	
	\vskip 4em
		
	\begin{center}
		{Simon Fraser University\par
		School of Engineering Science}
	\end{center}
	
	\vskip 2em

	\begin{center}
		{\@date\par
		\vskip 2em
		{\Large Course Instructor: \@prof}}
	\end{center}
	
	\vskip 4em
\end{titlepage}
}