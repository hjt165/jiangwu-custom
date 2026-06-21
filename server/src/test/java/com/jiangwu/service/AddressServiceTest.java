package com.jiangwu.service;

import com.jiangwu.dto.request.CreateAddressRequest;
import com.jiangwu.dto.response.AddressResponse;
import com.jiangwu.entity.Address;
import com.jiangwu.exception.BusinessException;
import com.jiangwu.repository.AddressRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AddressServiceTest {

    @Mock private AddressRepository addressRepository;
    @InjectMocks private AddressService addressService;

    private Address testAddress;

    @BeforeEach
    void setUp() {
        testAddress = new Address();
        testAddress.setId(1L);
        testAddress.setUserId(1L);
        testAddress.setName("张三");
        testAddress.setPhone("13800000000");
        testAddress.setProvince("浙江省");
        testAddress.setCity("杭州市");
        testAddress.setDistrict("西湖区");
        testAddress.setDetail("文三路123号");
        testAddress.setIsDefault(1);
    }

    @Test
    void getAddresses_ReturnsList() {
        when(addressRepository.findByUserId(1L)).thenReturn(List.of(testAddress));
        List<AddressResponse> result = addressService.getAddresses(1L);
        assertEquals(1, result.size());
        assertEquals("张三", result.get(0).getName());
    }

    @Test
    void getAddress_ValidOwner_ReturnsAddress() {
        when(addressRepository.findById(1L)).thenReturn(testAddress);
        AddressResponse result = addressService.getAddress(1L, 1L);
        assertNotNull(result);
        assertEquals("张三", result.getName());
    }

    @Test
    void getAddress_WrongOwner_ThrowsException() {
        when(addressRepository.findById(1L)).thenReturn(testAddress);
        assertThrows(BusinessException.class, () -> addressService.getAddress(2L, 1L));
    }

    @Test
    void getAddress_NotFound_ThrowsException() {
        when(addressRepository.findById(999L)).thenReturn(null);
        assertThrows(BusinessException.class, () -> addressService.getAddress(1L, 999L));
    }

    @Test
    void createAddress_Success() {
        doReturn(1).when(addressRepository).insert(any(Address.class));
        CreateAddressRequest request = new CreateAddressRequest();
        request.setName("李四");
        request.setPhone("13900000000");
        request.setProvince("浙江省");
        request.setCity("杭州市");
        request.setDistrict("滨江区");
        request.setDetail("网商路456号");
        request.setIsDefault(false);

        AddressResponse result = addressService.createAddress(1L, request);
        assertNotNull(result);
    }

    @Test
    void createAddress_SetDefault_ClearsOthers() {
        doReturn(1).when(addressRepository).clearDefault(1L);
        doReturn(1).when(addressRepository).insert(any(Address.class));
        CreateAddressRequest request = new CreateAddressRequest();
        request.setName("李四");
        request.setPhone("13900000000");
        request.setProvince("浙江省");
        request.setCity("杭州市");
        request.setDistrict("滨江区");
        request.setDetail("网商路456号");
        request.setIsDefault(true);

        addressService.createAddress(1L, request);
        verify(addressRepository).clearDefault(1L);
    }

    @Test
    void updateAddress_Success() {
        when(addressRepository.findById(1L)).thenReturn(testAddress);
        doReturn(1).when(addressRepository).updateById(any(Address.class));
        CreateAddressRequest request = new CreateAddressRequest();
        request.setName("张三");
        request.setPhone("13800000000");
        request.setProvince("浙江省");
        request.setCity("杭州市");
        request.setDistrict("西湖区");
        request.setDetail("文三路456号");
        request.setIsDefault(false);

        AddressResponse result = addressService.updateAddress(1L, 1L, request);
        assertNotNull(result);
    }

    @Test
    void deleteAddress_Success() {
        when(addressRepository.findById(1L)).thenReturn(testAddress);
        addressService.deleteAddress(1L, 1L);
        verify(addressRepository).deleteById(1L);
    }

    @Test
    void deleteAddress_WrongOwner_ThrowsException() {
        when(addressRepository.findById(1L)).thenReturn(testAddress);
        assertThrows(BusinessException.class, () -> addressService.deleteAddress(2L, 1L));
    }

    @Test
    void setDefault_Success() {
        when(addressRepository.findById(1L)).thenReturn(testAddress);
        doReturn(1).when(addressRepository).clearDefault(1L);
        doReturn(1).when(addressRepository).updateById(any(Address.class));

        addressService.setDefault(1L, 1L);
        verify(addressRepository).clearDefault(1L);
    }
}
