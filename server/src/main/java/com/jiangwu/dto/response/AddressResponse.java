package com.jiangwu.dto.response;

import com.jiangwu.entity.Address;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 收货地址响应 DTO
 */
@Data
public class AddressResponse {

    private Long id;
    private String name;
    private String phone;
    private String province;
    private String city;
    private String district;
    private String detail;
    private Boolean isDefault;
    private LocalDateTime createdAt;

    public static AddressResponse fromEntity(Address address) {
        if (address == null) return null;
        AddressResponse dto = new AddressResponse();
        dto.setId(address.getId());
        dto.setName(address.getName());
        dto.setPhone(address.getPhone());
        dto.setProvince(address.getProvince());
        dto.setCity(address.getCity());
        dto.setDistrict(address.getDistrict());
        dto.setDetail(address.getDetail());
        dto.setIsDefault(address.getIsDefault() != null && address.getIsDefault() == 1);
        dto.setCreatedAt(address.getCreatedAt());
        return dto;
    }
}
