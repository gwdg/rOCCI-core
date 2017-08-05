# :nodoc:
class IPAddr
  AF_INET_FULL_MASK = 32
  AF_INET6_FULL_MASK = 128

  attr_reader :mask_addr

  # Converts network mask to CIDR format.
  #
  # @return [Integer] CIDR representation of address mask
  def cidr_mask
    case family
    when Socket::AF_INET
      AF_INET_FULL_MASK - Math.log2((1 << AF_INET_FULL_MASK) - mask_addr).to_i
    when Socket::AF_INET6
      AF_INET6_FULL_MASK - Math.log2((1 << AF_INET6_FULL_MASK) - mask_addr).to_i
    else
      raise AddressFamilyError, 'unsupported address family'
    end
  end

  # :nodoc:
  def host?
    case family
    when Socket::AF_INET
      cidr_mask == AF_INET_FULL_MASK
    when Socket::AF_INET6
      cidr_mask == AF_INET6_FULL_MASK
    else
      raise AddressFamilyError, 'unsupported address family'
    end
  end

  # :nodoc:
  def network?
    !host?
  end
end
