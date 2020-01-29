classdef Displayable
    % A mix-in class for custom display with dispstr() and dispstrs()
    %
    % To use this, inherit from it, and define a custom dispstrs() method. It
    % will be picked up and used by dispstr() and disp(), which will also make
    % display() respect it.
    %
    % Examples:
    %
    % classdef mydate < dispstrlib.Displayable
    %     % An example of using Displayable
    %     %
    %     % (Don't actually implement dates like this! It's super slow; you need to use
    %     % planar-organized objects instead.)
    %     properties
    %         theDatenum double = NaN
    %     end
    %
    %     methods
    %         function this = mydate(dnums)
    %             if nargin == 0
    %                 return;
    %             end
    %             this = repmat(this, size(dnums));
    %             for i = 1:numel(dnums)
    %                 this(i).theDatenum = dnums(i);
    %             end
    %         end
    %
    %         function out = dispstrs(this)
    %             out = cell(size(this));
    %             for i = 1:numel(this)
    %                 dn = this(i).theDatenum;
    %                 if isnan(dn)
    %                     out{i} = 'NaN';
    %                 else
    %                     out{i} = datestr(this(i).theDatenum);
    %                 end
    %             end
    %         end
    %     end
    % end
    
  
  methods
    
    function disp(this)
      %DISP Custom display
      disp(dispstr(this));
    end
    
    function out = dispstr(this)
      %DISPSTR Custom display string
      if isscalar(this)
        strs = dispstrs(this);
        out = strs{1};
      else
        out = sprintf('%s %s', size2str(size(this)), class(this));
      end
    end
    
    function out = dispstrs(this)
      out = cell(size(this));
      for i = 1:numel(this)
        out{i} = dispstr_scalar(subsref(this, ...
          struct('type','()', 'subs',{{i}})));
      end
    end
    
    function error(varargin)
      args = convertDisplayablesToString(varargin);
      err = MException(args{:});
      throwAsCaller(err);
    end
    
    function warning(varargin)
      args = convertDisplayablesToString(varargin);
      warning(args{:});
    end
    
    function out = sprintf(varargin)
      args = convertDisplayablesToString(varargin);
      out = sprintf(args{:});
    end
    
    function out = fprintf(varargin)
      args = convertDisplayablesToString(varargin);
      out = sprintf(args{:});
    end
    
  end
  
  methods (Access = protected)
    
    function out = dispstr_scalar(this) %#ok<STOUT>
      error('jl:Unimplemented', ['Subclasses of Displayable must override ' ...
        'dispstr_scalar; %s does not'], ...
        class(this));
    end
    
    function dispMaybeMatrix(this)
      if ~ismatrix(this)
        disp(dispstr(this));
        return
      elseif isempty(this)
        if isequal(size(this), [0 0])
          fprintf('[] (%s)\n', class(this));
        else
          fprintf('Empty %s %s array\n', size2str(size(this)), ...
            class(this));
        end
      else
        strs = dispstrs(this);
        nCols = size(strs, 2);
        colWidths = NaN(1, nCols);
        for i = 1:nCols
          colWidths(i) = max(strlen(strs(:,i)));
        end
        fmt = [strjoin(repmat({'%*s'}, [1 nCols]), '  ') '\n'];
        for iRow = 1:size(strs, 1)
          args = [num2cell(colWidths); strs(iRow,:)];
          args = args(:);
          fprintf(fmt, args{:});
        end
      end
    end
    
  end
end

function out = convertDisplayablesToString(c)
mustBeA(c, 'cell');
out = c;
for i = 1:numel(c)
  if isa(c{i}, 'dispstrlib.Displayable')
    out{i} = dispstr(c{i});
  end
end
end