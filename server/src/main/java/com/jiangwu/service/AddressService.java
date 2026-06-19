package com.jiangwu.service;

import com.jiangwu.dto.request.CreateAddressRequest;
import com.jiangwu.dto.response.AddressResponse;
import com.jiangwu.entity.Address;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.exception.ErrorCode;
import com.jiangwu.repository.AddressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 收货地址服务
 */
@Service
@RequiredArgsConstructor
public class AddressService {

    private final AddressRepository addressRepository;

    /**
     * 获取用户所有地址
     */
    public List<AddressResponse> getAddresses(Long userId) {
        List<Address> addresses = addressRepository.findByUserId(userId);
        return addresses.stream()
                .map(AddressResponse::fromEntity)
                .collect(Collectors.toList());
    }

    /**
     * 获取单个地址
     */
    public AddressResponse getAddress(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId);
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND);
        }
        return AddressResponse.fromEntity(address);
    }

    /**
     * 新增地址
     */
    @Transactional
    public AddressResponse createAddress(Long userId, CreateAddressRequest request) {
        Address address = new Address();
        address.setUserId(userId);
        address.setName(request.getName());
        address.setPhone(request.getPhone());
        address.setProvince(request.getProvince());
        address.setCity(request.getCity());
        address.setDistrict(request.getDistrict());
        address.setDetail(request.getDetail());
        address.setIsDefault(Boolean.TRUE.equals(request.getIsDefault()) ? 1 : 0);

        // 如果设为默认，先清除其他默认
        if (Boolean.TRUE.equals(request.getIsDefault())) {
            addressRepository.clearDefault(userId);
        }

        addressRepository.insert(address);
        return AddressResponse.fromEntity(address);
    }

    /**
     * 更新地址
     */
    @Transactional
    public AddressResponse updateAddress(Long userId, Long addressId, CreateAddressRequest request) {
        Address address = addressRepository.findById(addressId);
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND);
        }

        address.setName(request.getName());
        address.setPhone(request.getPhone());
        address.setProvince(request.getProvince());
        address.setCity(request.getCity());
        address.setDistrict(request.getDistrict());
        address.setDetail(request.getDetail());

        boolean wantDefault = Boolean.TRUE.equals(request.getIsDefault());
        if (wantDefault && (address.getIsDefault() == null || address.getIsDefault() != 1)) {
            addressRepository.clearDefault(userId);
            address.setIsDefault(1);
        } else if (!wantDefault) {
            address.setIsDefault(0);
        }

        addressRepository.updateById(address);
        return AddressResponse.fromEntity(address);
    }

    /**
     * 删除地址
     */
    public void deleteAddress(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId);
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND);
        }
        addressRepository.deleteById(addressId);
    }

    /**
     * 设为默认地址
     */
    @Transactional
    public void setDefault(Long userId, Long addressId) {
        Address address = addressRepository.findById(addressId);
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException(ErrorCode.NOT_FOUND);
        }
        addressRepository.clearDefault(userId);
        address.setIsDefault(1);
        addressRepository.updateById(address);
    }
}
