%load tes.mat

function eigenvectors = pcafunc(struktur, dim)

%data=X;
%function pcatest(data)

%data = [1 2 3 4; 4 5 6 3; 2 3 4 1; 1 8  9 4 ]

data = struktur;

size(data);

%data = [ 2.5 2.4; 0.5 0.7; 2.2 2.9; 1.9 2.2; 3.1 3.0; 2.3 2.7; 2 1.6; 1 1.1; 1.5 1.6; 1.1 0.9;];

% data = x1 y1; x2 y2;

% PCA: Perform PCA using covariance
%
% data  - MxN matrix of input data transposed
%         M trials
%         N dimension


% PC - each Colum is a PC
% V  - Mx1 matrix 

N=size(data,1);  % Zeilenzahl

% subtract mean from each of the data dimensions 
mn = mean(data,1);

meandata = data - repmat(mn,N,1);



covmat = cov(meandata);
[PC,D] = eig(covmat);

% D diagonalmatrix of eigenvalues

DD=diag(D);

% sort the eigenvalues in decreasing order

[junk,rindices] = sort(DD,'descend');
DD=DD(rindices);
PC=PC(:,rindices);

% dimensions = Zahl der Komponenten

dimensions= dim;

finaleigs = PC(:,1:dimensions);

eigenvectors = finaleigs;

% prefinaldata = finaleigs'*meandata';
% % finaldata = prefinaldata'
% 
% ergebnis=finaleigs*prefinaldata;
% 
% ergend=ergebnis'+repmat(mn,N,1);