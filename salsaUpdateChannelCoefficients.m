function [successFlag Data] = salsaUpdateChannelCoefficients(Data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Program: salsaUpdateChannelCoefficients()                                                                                                               %  
%   Author: Baljeet Malhotra                                                                                                                                %
%   Date Created: July 16, 2010                                                                                                                             %
%   Last modified: Aug 12, 2010                                                                                                                             %
%   Input:                                                                                                                                                  %
%   Output:                                                                                                                                                 %
%   Example:                                                                                                                                                %
%   Comments: Update menue for channel coefficients.                                                                                                      %   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    default_ans = {'','','','','','',''};
    userAnswer = default_ans;
    title = 'Enter channel coefficients';
    prompt{1} = 'Intrument name (description): ';
    prompt{2} = 'Channel A, coefficient a: ';
    prompt{3} = 'Channel A, coefficient b: ';
    prompt{4} = 'Channel A, coefficient c: ';
    prompt{5} = 'Channel B, coefficient a: ';
    prompt{6} = 'Channel B, coefficient b: ';
    prompt{7} = 'Channel B, coefficient c: ';
    exitFlag = 0;
    successFlag = 0;
    while(exitFlag == 0)
        default_ans = userAnswer;
        userAnswer = inputdlg(prompt,title,1,default_ans,'off');
        if (isempty(userAnswer) == 1)
            tempStr = 'Selection cancelled by the user.';
            disp(tempStr);  
            choice = questdlg(tempStr, ...
                'SALSA', ...
                'Ok','Ok');
            if (isempty(choice) == 1)
                choice = 'Ok';
            end
            if (strcmp(choice,'Ok') == 1)
                exitFlag = 1;
            end
        elseif (isempty(userAnswer{1}) == 1)
            tempStr = 'Enter a valid instrument name (description).';
            disp(tempStr);  
            choice = questdlg(tempStr, ...
                'SALSA', ...
                'Ok','Ok');
            if (isempty(choice) == 1)
                choice = 'Ok';
            end
            if (strcmp(choice,'Ok') == 1)
            end
        elseif (isnan(str2double(userAnswer{2})) == 1 || isnan(str2double(userAnswer{3})) == 1 || isnan(str2double(userAnswer{4})) == 1 || isnan(str2double(userAnswer{5})) == 1 || isnan(str2double(userAnswer{6})) == 1 || isnan(str2double(userAnswer{7})) == 1)
            tempStr = 'Wrong value of coefficient(s).';
            disp(tempStr);  
            choice = questdlg(tempStr, ...
                'SALSA', ...
                'Ok','Ok');
            if (isempty(choice) == 1)
                choice = 'Ok';
            end
            if (strcmp(choice,'Ok') == 1)
            end
        else
            Instruments = Data{1,1};
            Coeffecients = Data{1,2};
            Instruments{length(Instruments)+1} = userAnswer{1};
            Data{1,1} = Instruments;
            Coeffecients(size(Coeffecients,1)+1,:) = [str2double(userAnswer{2}) str2double(userAnswer{3}) str2double(userAnswer{4}) str2double(userAnswer{5}) str2double(userAnswer{6}) str2double(userAnswer{7})];
            Data{1,2} = Coeffecients;         
            save('salsaMetaData.mat', 'Data');
            exitFlag = 1;
            successFlag = 1;
        end
    end
    